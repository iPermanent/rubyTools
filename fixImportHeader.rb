#!/usr/bin/ruby
# -*- coding: UTF-8 -*-
# author zhangheng
#功能，一次性自动替换 使用双引号导入的头文件为尖括号<xx/xx.h>
#用法，放入组件根目录，直接ruby fixImportHeader.rb即可，
#但是注意，一定要是在组件正常引入所有的依赖并且pod install以后
#因为寻找header所在的pods需要pod install 成功，才能根据结构查找到header所属模块

@cache_pod_maps

def replace_action
    #获取当前工程目录，一般主工程目录里还有一层同名的，如果需要可以自行修改
    projectName = File.basename(Dir.getwd)
    projectDir = Dir.getwd + "/" + projectName

    Dir.glob(projectDir + "/**/**/**/**").each do |name|
        next if Dir.exists? name
        text = File.read(name)
        for find, replace in @string_replacements
            text = text.gsub(find, replace)
        end

        File.open(name, "w") { |file| file.puts text }
      end
end

#查找引入方式不正确的header
def findFixImportHeaders
    @cache_pod_maps = Hash.new
    projectName = File.basename(Dir.getwd)
    projectDir = Dir.getwd + "/" + projectName

    Dir.glob(projectDir + "/**/**/**/**.{h,m}").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        #以import "xx.h"的引入
        pattern = /#import \S+\.h"/
        results = text.scan(pattern)

        #以#import开头.h>结尾的正则
        pattern2 = /#import \S+\.h>/
        results2 = text.scan(pattern2)

        hasContentNeedFix = false

        for result in results
          #取后面的xxx.h
          headerSuffix = result.split("\"")[1].gsub("\"","")
          podFolderName = getPodName(headerSuffix)
          if !podFolderName.nil?
            headerSuffix = headerSuffix.gsub("\"","")
            toReplaceImport = "#import <" + podFolderName + "/" + headerSuffix + ">"

            #执行替换
            text = text.gsub(result,toReplaceImport)
            puts("执行替换" + result + "  =>  " + toReplaceImport)
            hasContentNeedFix = true
            end
          end

        for result2 in results2
            #import <xx.h>此种方式
            if result2.split("/").count == 1
                #如果不包含/说明是不规范的导入需要修改
                headerFileName = result2.split("<")[1].gsub(">","")
                podName = getPodName(headerFileName)

                if !podName.nil?
                    replaceImportString = "#import <" + podName + "/" + headerFileName + ">"
                    text = text.gsub(result2,replaceImportString)

                    puts("执行替换" + result2 + "  =>  " + replaceImportString)
                    hasContentNeedFix = true
                end
            end
        end
        
        if hasContentNeedFix 
            puts("开始写文件=> " + name.gsub(projectDir,""))
            File.open(name, "w") { |file| file.puts text }
        end

        
      end
      puts("替换完成")
end

def getPodName(headerFileName)
  if @cache_pod_maps[headerFileName] != nil
    return @cache_pod_maps[headerFileName]
  end
    
  podDir = Dir.getwd + "/Example/Pods"
  headerDir = podDir + "/Headers"
  Dir.glob(podDir + "/**/**/**/**.{h}").each do |name|
    next if Dir.exists? name
    if !name.start_with?(headerDir) && name.end_with?("/" + headerFileName)
      tempDir = name.gsub(podDir + "/","")  #删除掉前方pod路径方便操作
      podFolder = tempDir.split("/")[0]#通过取到 pod的第一层目录为pod名
        
      @cache_pod_maps[headerFileName] = podFolder
        
      return podFolder
    end
  end
  #默认给出nil返回值
  return nil
end

findFixImportHeaders
