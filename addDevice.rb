#!/usr/bin/ruby
# -*- coding: UTF-8 -*-

require "spaceship"

def readDeviceList
    #开始登录
    appleAccount = nil
    while appleAccount == nil  || appleAccount.length == 0
        puts("请输入开发者账号")
        appleAccount = gets.to_s.gsub("\n","")
    end

    applePassword = nil
    while applePassword == nil || applePassword.length == 0
        puts("请输入开发者账号的密码")
        applePassword = gets.to_s.gsub("\n","")
    end

    puts("开始登录中... |#{appleAccount}|#{applePassword}|")

    #### 如果懒得输入，注释掉以上内容，在下方填入自己的账号密码即可
    # appleAccount = ""
    # applePassword = ""
    puts("开始登录中...  #{appleAccount}")
    Spaceship.login(appleAccount, applePassword)
    puts "登录成功，选择所属team"

    teamIds = Spaceship.select_team

    deviceListTextFile = nil
    while deviceListTextFile == nil or deviceListTextFile.length == 0
        puts "输入txt文件，可直接将文件拖至终端"
        txtPath = gets.to_s.gsub("\n","").gsub("\t","").gsub(" ","")
        if File.exist?(txtPath)
            deviceListTextFile = txtPath
        else
            puts "文件不存在，请重新输入"
        end
    end

    #本地的文件路径
    file = File.open(deviceListTextFile) #文本文件里录入的udid和设备名用tab分隔
    file.each do |line|
        arr = line.split(" | ")
        device = Spaceship.device.create!(name: arr[1], udid: arr[0])
        puts "add device: #{device.name} #{device.udid} #{device.model}"
    end

    devices = Spaceship.device.all

    profiles = Array.new
    profiles += Spaceship.provisioning_profile.development.all
    profiles += Spaceship.provisioning_profile.ad_hoc.all

    puts("有以下provision,请选择需要的进行更新,输入前面的序号即可,如需多个请以英文逗号隔开,如1,2,3,4,如果需要更新所有的provision请输入all")
    profiles.each do |p|
        puts("#{profiles.find_index(p)} #{p.name}")
    end

    dealProfiles = nil
    while dealProfiles == nil or dealProfiles.length == 0
        puts "请选择需要更新的provision文件，以序号表示，用英文逗号隔开"

        dealProfiles = gets.to_s.gsub("\n","")
    end

    needDownloadProfileUuids = Array.new

    if dealProfiles == "all"
        #更新全部配置文件
        puts "开始更新全部配置文件"
        profiles.each do |p|
            needDownloadProfileUuids.append(p.name)
            puts "Updating #{p.name}"
            p.devices = devices
            p.update!
        end

        downloadProfiles(needDownloadProfileUuids)
    else
        puts "开始更新指定配置文件 #{dealProfiles.split(",")}"
        needUpdateProfiles = Array.new
        indexes = dealProfiles.split(",")

        #取需要更新的配置文件列表
        indexes.each do |idx|
            profile = profiles[idx.to_i]
            needUpdateProfiles.append(profile)
            needDownloadProfileUuids.append(profile.name)
        end

        #开始更新配置文件 
        needUpdateProfiles.each do |p|
            puts "update profiles #{p.name}"
            p.devices = devices
            p.update!
        end

        downloadProfiles(needDownloadProfileUuids)
    end
end

def downloadProfiles(names)
    profiles = Array.new
    profiles += Spaceship.provisioning_profile.development.all
    profiles += Spaceship.provisioning_profile.ad_hoc.all

    puts "开始下载provision文件 #{names}"

    downloadFolder = __dir__ + '/Provisions/'
    #防止没有目录时报错，需要创建一下目录
    mkDirCmdStr = "mkdir -p #{downloadFolder}"
    system(mkDirCmdStr)
    profiles.each do |p|
        if names.include?(p.name)
            puts "Downloading profile #{p.name}"
            File.write("#{downloadFolder}#{p.name}.mobileprovision", p.download)
        end
    end

    puts "下载完毕，请在目录 #{downloadFolder} 里找到并双击安装provision文件"
    system("open #{downloadFolder}")
end

#读取设备列表
readDeviceList

