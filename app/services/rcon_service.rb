require 'socket'

class RconService
  class RconError < StandardError; end

  SERVERDATA_AUTH = 3
  SERVERDATA_AUTH_RESPONSE = 2
  SERVERDATA_EXECCOMMAND = 2
  SERVERDATA_RESPONSE_VALUE = 0

  def initialize(host, port, password)
    @host = host
    @port = port
    @password = password
    @socket = nil
    @request_id = 0
  end

  def connect
    begin
      Rails.logger.info "Connecting to RCON at #{@host}:#{@port}"
      @socket = TCPSocket.new(@host, @port)
      Rails.logger.info "Connected to RCON server, attempting authorization"
      authorize
      Rails.logger.info "RCON authorization successful"
      self
    rescue => e
      Rails.logger.error "RCON connection error: #{e.message}"
      raise RconError, "Failed to connect to RCON server: #{e.message}"
    end
  end

  def disconnect
    @socket&.close
    @socket = nil
  end

  def send_command(command)
    raise RconError, "Not connected" unless @socket
    Rails.logger.info "Sending command to RCON: #{command}"

    begin
      Rails.logger.debug "Setting socket options..."
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [5, 0].pack('l_*'))

      request_id = next_request_id
      Rails.logger.debug "Sending command packet with ID: #{request_id}"
      send_packet(SERVERDATA_EXECCOMMAND, command)

      # Read the response packets
      response_text = ""

      # First packet (command response)
      Rails.logger.debug "Reading first response packet..."
      response1 = read_packet

      if !response1
        Rails.logger.error "No response received"
        raise RconError, "No response received"
      elsif response1[:id] != request_id
        Rails.logger.error "Response ID mismatch: expected #{request_id}, got #{response1[:id]}"
        raise RconError, "Response ID mismatch"
      end

      response_text = response1[:body]
      Rails.logger.debug "First response: #{response_text}"

      # Second packet (empty terminator)
      Rails.logger.debug "Reading second (terminator) packet..."
      response2 = read_packet

      if response2
        Rails.logger.debug "Second response: #{response2[:body]}"
        # Some servers might include additional data in the second packet
        if response2[:body] && !response2[:body].empty?
          response_text += response2[:body]
        end
      end

      return response_text
    rescue => e
      Rails.logger.error "RCON command error: #{e.message}"
      disconnect
      raise RconError, "RCON command failed: #{e.message}"
    end
  end

  private

  def authorize
    send_packet(SERVERDATA_AUTH, @password)

    # Set a timeout for the auth response
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [5, 0].pack('l_*'))

    response = read_packet

    if !response || response[:id] == -1
      disconnect
      raise RconError, "Authentication failed"
    end
  end

  def send_packet(type, body)
    packet = build_packet(type, body)

    bytes_sent = 0

    # Send packet with timeout
    begin
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, [5, 0].pack('l_*'))
      bytes_sent = @socket.write(packet)
    rescue => e
      raise RconError, "Send error: #{e.message}"
    end

    if bytes_sent != packet.bytesize
      raise RconError, "Failed to send complete packet"
    end
  end

  def build_packet(type, body)
    request_id = next_request_id
    # Size is the length of the packet content (not including the size field itself)
    # 4 bytes for request_id + 4 bytes for type + body length + 2 null terminators
    size = 4 + 4 + body.bytesize + 2

    [size, request_id, type, body, "\x00\x00"].pack("VVVa*a*")
  end

  def read_packet
    begin
      Rails.logger.debug "Reading packet header..."

      response = read_rcon_response(@socket)

      if !response[:body]
        Rails.logger.debug "Failed to read packet body"
        return nil
      end

      # Extract string up to the first null byte
      body_str = response[:body].unpack("Z*")[0] || ""
      Rails.logger.debug "Packet body: #{body_str.inspect}"

      return { id: response[:id], type: response[:type], body: body_str }
    rescue Timeout::Error => e
      Rails.logger.error "Timeout reading packet: #{e.message}"
      raise RconError, "Timeout reading packet: #{e.message}"
    rescue => e
      Rails.logger.error "RCON read error: #{e.message}"
      raise RconError, "Read error: #{e.message}"
    end
  end

  def next_request_id
    @request_id += 1
  end

  def read_rcon_response(socket)
    # Read the full response from socket
    response = ""
    while line = socket.gets
      response << line
    end

    return nil if response.empty?

    # Parse the response as RCON packet
    # First 4 bytes are size
    size = response.byteslice(0, 4).unpack('V')[0]

    # Extract and parse the packet
    packet = response.byteslice(4, size)
    return nil if packet.nil? || packet.empty?

    # Unpack the packet components
    request_id, type, body_with_null = packet.unpack('VVa*')

    # Extract body (removing the null terminator)
    body = body_with_null.chomp("\x00")

    # Return all three components
    return {
      id: request_id,
      type: type,
      body: body
    }
  end
end
