vrrp_script chk_haproxy {
        script "pidof haproxy"
        interval 5
        weight -4
        fall 2
        rise 1
}

vrrp_instance vrrp_${itr1} {
        interface ens3
        virtual_router_id ${itr1}
        state MASTER
        priority 201
        
        unicast_src_ip ${hap1_ip}
        unicast_peer {
            ${hap2_ip}
        }

        authentication {
                auth_type PASS
                auth_pass Secret
        }
        
        track_script {
                chk_haproxy
        }

        notify_master /etc/keepalived/ip_failback.sh
}

vrrp_instance vrrp_${itr2} {
        interface ens3
        virtual_router_id ${itr2}
        state BACKUP
        priority 200

        unicast_src_ip ${hap1_ip}
        unicast_peer {
            ${hap2_ip}
        }

        authentication {
                auth_type PASS
                auth_pass Secret
        }

        track_script {
                chk_haproxy
        }

        notify_backup /etc/keepalived/ip_failback_sec.sh
        notify_master /etc/keepalived/ip_failover.sh
}
