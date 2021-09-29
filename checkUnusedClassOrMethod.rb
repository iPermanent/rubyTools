## usage: ruby checkUnusedClassOrMethod.rb 【optioal】machofilePath [-c][-s](means class or selector)
## need to install snake，please run 'brew install snake' in terminal first
##
require 'json'

def parseUnusedClass
    txtDir = __dir__ + "/" + "classUnused.txt"

    machOFilePath  = ARGV[0]
    if !machOFilePath
      puts("please specfic a macho file path...")
      return
    end

    unusedClassCmd = 'snake -c -j ' + machOFilePath + ' > ' + txtDir
    snakeResult = system(unusedClassCmd)
    if !snakeResult
        puts("脚本调用失败，不妨试试 brew install snake ?")
        return
    else
        puts("执行结束，开始分析筛选")
    end


    filtArray = Array.new()

    text = File.read(txtDir).gsub("\"","").gsub("[","").gsub("]","")

    classArray = text.split(",")

    for className in classArray
      filtArray.push(className)   
    end

    writeContent = filtArray.join(",\n")

    logFilePath = __dir__ + "/classUnusedWithFilter.txt"
    if !Dir.exists?(logFilePath)
        File.new(logFilePath,'w')
    end
    File.open(logFilePath, "w") do |f|
        f.write(writeContent)
    end
    File.delete(txtDir) if File.exist?(txtDir)
    puts("分析结束，请到：" + logFilePath + " 查看最终分析结果")
end

#针对单个结果分析
def filterClassStructor(classMethodStructMap)
    #set方法排除,同样，有get的方法也要排除
    setSelectorsArray = Array.new()
    normalSelectorArray = Array.new()

    allSelectorsArray = classMethodStructMap["selectors"]

    #分出set方法和非方法
    for functionName in allSelectorsArray
        functionActureName = functionName.split(" ")[1].gsub("]","")
        #是set方法,当有多个:说明是多个参数，不属于set方法
        if functionActureName.start_with?("set") and functionActureName.end_with?(":") and functionActureName.split(":").count == 1
            #setAbc: => abc set向get方法转换
            getFunctionName = functionActureName.split(":")[0].gsub("set","").downcase
            setSelectorsArray.push(getFunctionName)
        else
            normalSelectorArray.push(functionActureName)
        end
    end

    #相减即为非get也非set方法
    normalSelectorArray = normalSelectorArray - setSelectorsArray

    finalResultMaps = Hash.new()
    if normalSelectorArray.count > 0
        className = classMethodStructMap["class"]
        finalResultMaps[className] = normalSelectorArray
    end

    return finalResultMaps
end

def parseUnusedSelector
    txtDir = __dir__ + "/" + "methodUnused.txt"

    machOFilePath  = ARGV[0]
    if !machOFilePath
      puts("please specfic a macho file path...")
      return
    end

    unusedClassCmd = 'snake -s -j ' + machOFilePath + ' > ' + txtDir
    snakeResult = system(unusedClassCmd)
    if !snakeResult
        puts("脚本调用失败，不妨试试 brew install snake ?")
        return
    else
        puts("执行结束，开始分析筛选")
    end

    jsonText = File.read(txtDir)
    selectorStruct = JSON.parse(jsonText)

    finalFilterMap = Array.new()

    for methodMap in selectorStruct
        filterMap = filterClassStructor(methodMap)
        if !filterMap.empty?()
          className = filterMap.keys[0]
          finalFilterMap.push(filterMap) 
        end
    end
    
    separateResult = Hash.new()
    separateResult["ClassUnUsedMethodResult"] = finalFilterMap

    jsonDir = __dir__ + "/" + "classMethodUnused.json"
    File.write(jsonDir,JSON.pretty_generate(separateResult))
    File.delete(txtDir) if File.exist?(txtDir)
    puts("分析结果已输出至：" + jsonDir + " 请打开查看")
end

def startParseMachO
    machOFilePath  = ARGV[0]
    parseWay = ARGV[1]

    if !machOFilePath or machOFilePath.length == 0
        puts("请指定machO文件路径 useage .rb xxxx/xxx/xx")
        return
    end

    if !parseWay or parseWay.length == 0
        puts("指定方式 -s为分析无用方法 -c为分析无用类")
        return
    end

    if parseWay == '-s'
        parseUnusedSelector()
    elsif parseWay == '-c' 
        parseUnusedClass()
        puts("请谨慎删除相关类，特别是在很多类里使用反射方式，通过string拿到class时，mach-O文件内未关联此种引用造成误报")
    end

end

startParseMachO
