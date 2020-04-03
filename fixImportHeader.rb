#!/usr/bin/ruby
# -*- coding: UTF-8 -*-
# author zhangheng
#功能，一次性自动替换 使用双引号导入的头文件为尖括号<xx/xx.h>

#工程中多文本字段替换时可用,xcode已有同样功能
def runReplaceValAction
    @string_replacements = {
        "[HTAppHierarchy sharedInstance]" => "HTHierarchyModule",
        "test data" => "测试数据"
    }
    replace_action
end

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
    projectName = File.basename(Dir.getwd)
    projectDir = Dir.getwd + "/" + projectName

    Dir.glob(projectDir + "/**/**/**/**.{h,m}").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        pattern = /#import "\S+\.h"/
        results = text.scan(pattern)
        for result in results
          podFolderName = getPodName(result)
          if !podFolderName.nil?
            
            #取后面的xxx.h
            headerSuffix = result.gsub("#import \"","")
            headerSuffix = headerSuffix.gsub("\"","")

            toReplaceImport = "#import <" + podFolderName + "/" + headerSuffix + ">"

            #执行替换
            text = text.gsub(result,toReplaceImport)
            puts("执行替换" + result + "  =>  " + toReplaceImport)
            end
          end
        File.open(name, "w") { |file| file.puts text }
      end
      puts("替换完成")
end

def getPodName(headerImport)
  headerName = headerImport.gsub("#import \"","")
  headerName = headerName.gsub("\"","")

  podDir = Dir.getwd + "/Example/Pods"
  headerDir = podDir + "/Headers"
  Dir.glob(podDir + "/**/**/**/**.{h}").each do |name|
    next if Dir.exists? name
    if !name.start_with?(headerDir) && name.end_with?(headerName)
      tempDir = name.gsub(podDir + "/","")  #删除掉前方pod路径方便操作
      podFolder = tempDir.split("/")[0]#通过取到 pod的第一层目录为pod名
      return podFolder
    end
  end
  #默认给出nil返回值
  return nil
end

findFixImportHeaders
