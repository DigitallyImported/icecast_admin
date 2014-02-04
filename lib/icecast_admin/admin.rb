module Icecast
  ResponseError = Class.new(RuntimeError)
  MountNotFoundError = Class.new(ResponseError)

  class Admin
    def initialize(ip, port, user, pass)
      @server_ip = ip
      @server_port = port
      @admin_user = user
      @admin_pass = pass
    end

    def list_mounts(verbose = false)
      if verbose
        response = Hash.from_xml(send_request('/admin/listclients'))[:icestats][:source]
        mounts = response.map { |mount|
          name = mount.delete(:attributes)
          {:name => name[:mount]}.merge mount
        }
      else
        response = Hash.from_xml(send_request('/admin/listmounts'))[:icestats][:source]
        mounts = response.map { |mount|
          {
            :name => mount[:attributes][:mount],
            :listeners => mount[:listeners],
            :uptime => mount[:Connected],
            :content_type => mount[:"content-type"]
          }
        }
      end
      mounts
    end

    def get_stats
      Hash.from_xml(send_request("/admin/stats"))[:icestats]
    end

    def list_clients(mount)
      response = Hash.from_xml(send_request("/admin/listclients?mount=#{mount}"))[:icestats][:source][:listener]
      return [] unless response
      response = Array[response] unless response.is_a? Array
      response.map { |client|
        {
          :id => client[:attributes][:id],
          :ip => client[:IP],
          :user_agent => client[:UserAgent],
          :lag => client[:lag],
          :connected => client[:Connected],
          :mount => mount
        }
      }
    rescue MountNotFoundError
     []
    end

    def find_client_by_ip(mount, ip)
      if mount
        return find_ip_in_mount(mount, ip)
      end

      list_mounts.each do |m|
        puts "Scanning #{m[:name]} for #{ip} ..."
        client = find_ip_in_mount(m[:name], ip)
        return client if client
      end
      nil
    end

    def find_ip_in_mount(mount, ip)
      clients = list_clients(mount)
      clients.each do |c|
        return c if c[:ip] == ip
      end
      nil
    end

    def kick_client(mount, client)
      if client.is_a?(String) && client.include?('.')
        client = find_client_by_ip(mount, client)[:id] rescue nil
      end

      response = Hash.from_xml send_request("/admin/killclient?mount=#{mount}&id=#{client}")
      (response[:iceresponse][:return] == 1)
    rescue MountNotFoundError
      false
    end

    private

    def send_request(path)
      http = Net::HTTP.new(@server_ip, @server_port)
      req = Net::HTTP::Get.new(path)
      req.basic_auth @admin_user, @admin_pass
      response = http.request(req)

      if response.code.to_i != 200
        err = response.body.gsub(/<\/?b>/i, '').strip
        raise case err
          when 'mount does not exist' || 'Source is not available' then MountNotFoundError.new
          else ResponseError.new(err)
        end
      end

      response.body
    end

  end
end
