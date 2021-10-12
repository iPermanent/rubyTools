
#用法，ruby podlockDependencyParse.rb /xx/xx/Podfile.lock 生成分析图，需要用到三方工具 graphviz,自行安装，推荐brew安装，不需要额外添加环境变量

class TyPodLib
    attr_accessor:pod_name
    attr_accessor:pod_dependencies 
end

def parsePodfilelock
    podLockFilePath = ARGV[0]

    podArray = Array.new    

    File.open(podLockFilePath) do |file|
        file.each_line do |line|
            #主pod
            if line.start_with?("  -")
                podlib = TyPodLib.new
                podlib.pod_dependencies = Array.new

                podName = line.split(" ")[1].gsub("\n","")
                podlib.pod_name = podName.split("/")[0].gsub("-","_").gsub("\"","")
                podArray.push(podlib)
            elsif line.start_with?("    -") #子pod依赖 ("    -")
                podlib = podArray[-1]
                puts(line)
                subpodName = line.split(" ")[1].gsub("\n","")
                subpodName = subpodName.split("/")[0]
                if subpodName != podlib.pod_name
                    podlib.pod_dependencies.push(subpodName.gsub("-","_").gsub("\"",""))
                end
            elsif line.start_with?("DEPENDENCIES:")
                #结束扫描，后面的不需要了
                break
            end
        end
    end

    generateImageData(podArray)
end

def generateImageData(arrayData)
    dotMainArray = Array.new
    dotRelateArray = Array.new

    for podlib in arrayData
        dotMainArray.push(podlib.pod_name + ";\n")
        for podDepenency in podlib.pod_dependencies
            dotRelateArray.push(podlib.pod_name + "->" + podDepenency + ";\n")
        end
    end

    #去重处理
    dotMainArray = dotMainArray.uniq()
    dotRelateArray = dotRelateArray.uniq()

    dotFileContent = "digraph dependencyRelation{\n"

    for mainContent in dotMainArray
        dotFileContent = dotFileContent + mainContent
    end

    for relateContent in dotRelateArray
        dotFileContent = dotFileContent + relateContent
    end

    dotFileContent = dotFileContent + "}"

    dotFilePath = __dir__ + "/" + "dependencyRelation.dot"

    if !Dir.exists?(dotFilePath)
        File.new(dotFilePath,'w')
    end
    File.open(dotFilePath, "w") do |f|
        f.write(dotFileContent)
    end

    generateImageCmdString = "fdp -Tpng dependencyRelation.dot -o dependencyRelation.png"
    system(generateImageCmdString)
end

parsePodfilelock
