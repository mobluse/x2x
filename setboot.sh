#!/bin/sh

INTERACTIVE=0
ASK_TO_REBOOT=0
BLACKLIST=/etc/modprobe.d/raspi-blacklist.conf
CONFIG=/boot/config.txt

get_init_sys() {
  if command -v systemctl > /dev/null && systemctl | grep -q '\-\.mount'; then
    SYSTEMD=1
  elif [ -f /etc/init.d/cron ] && [ ! -h /etc/init.d/cron ]; then
    SYSTEMD=0
  else
    echo "Unrecognised init system"
    return 1
  fi
}

disable_raspi_config_at_boot() {
  if [ -e /etc/profile.d/raspi-config.sh ]; then
    rm -f /etc/profile.d/raspi-config.sh
    if [ $SYSTEMD -eq 1 ]; then
      if [ -e /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf ]; then
        rm /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf
      fi
    else
      sed -i /etc/inittab \
        -e "s/^#\(.*\)#\s*RPICFG_TO_ENABLE\s*/\1/" \
        -e "/#\s*RPICFG_TO_DISABLE/d"
    fi
    telinit q
  fi
}

do_boot_behaviour_new() {
  if [ "$INTERACTIVE" = True ]; then
    BOOTOPT=$(whiptail --title "Raspberry Pi Software Configuration Tool (raspi-config)" --menu "Boot Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
      "B1 Console" "Text console, requiring user to login" \
      "B2 Console Autologin" "Text console, automatically logged in as 'pi' user" \
      "B3 Desktop" "Desktop GUI, requiring user to login" \
      "B4 Desktop Autologin" "Desktop GUI, automatically logged in as 'pi' user" \
      3>&1 1>&2 2>&3)
  else
    get_init_sys
    BOOTOPT=$1
    true
  fi
  if [ $? -eq 0 ]; then
    case "$BOOTOPT" in
      B1*)
        if [ $SYSTEMD -eq 1 ]; then
          systemctl set-default multi-user.target
          ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
        else
          [ -e /etc/init.d/lightdm ] && update-rc.d lightdm disable 2
          sed /etc/inittab -i \
 -e "s/1:2345:respawn:\/bin\/login -f pi tty1 <\/dev\/tty1 >\/dev\/tty1 2>&1/1:2345:respawn:\/sbin\/getty --noclear 38400 tty1/"
        fi
        ;;
      B2*)
        if [ $SYSTEMD -eq 1 ]; then
          systemctl set-default multi-user.target
          ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
        else
          [ -e /etc/init.d/lightdm ] && update-rc.d lightdm disable 2
          sed /etc/inittab -i \
 -e "s/1:2345:respawn:\/sbin\/getty --noclear 38400 tty1/1:2345:respawn:\/bin\/login -f pi tty1 <\/dev\/tty1 >\/dev\/tty1 2>&1/"
        fi
        ;;
      B3*)
        if [ -e /etc/init.d/lightdm ]; then
          if [ $SYSTEMD -eq 1 ]; then
            systemctl set-default graphical.target
            ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
          else
            update-rc.d lightdm enable 2
          fi
          sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=pi/#autologin-user=/"
          disable_raspi_config_at_boot
        else
          whiptail --msgbox "Do sudo apt-get install lightdm to allow configuration of boot to desktop" 20 60 2
          return 1
        fi
        ;;
      B4*)
        if [ -e /etc/init.d/lightdm ]; then
          if id -u pi > /dev/null 2>&1; then
            if [ $SYSTEMD -eq 1 ]; then
              systemctl set-default graphical.target
              ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
            else
              update-rc.d lightdm enable 2
            fi
            sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"
            disable_raspi_config_at_boot
          else
            whiptail --msgbox "The pi user has been removed, can't set up boot to desktop" 20 60 2
          fi
        else
          whiptail --msgbox "Do sudo apt-get install lightdm to allow configuration of boot to desktop" 20 60 2
          return 1
        fi
        ;;
      *)
        whiptail --msgbox "Programmer error, unrecognised boot option" 20 60 2
        return 1
        ;;
    esac
    ASK_TO_REBOOT=1
  fi
}

do_boot_behaviour_new $1
