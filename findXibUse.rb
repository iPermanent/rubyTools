def findXibs
    projectName = File.basename(Dir.getwd)
    projectDir = Dir.getwd + "/" + projectName
    
    xibResults = Array.new()
    Dir.glob(projectDir + "/**/**/**/**.{xib}").each do |name|
        next if Dir.exists? name

        filePaths = name.split("/")

        xibFile = filePaths[filePaths.count - 1]
        xibName = xibFile.gsub(".xib","")
        
        xibResults.push(xibName)
    end
    # puts(xibResults)
    return xibResults
end

def findCoponentXibUsageInMainPrj(xibFileClassName)
    #修改路径为自己需检测的主工程目录
    mainProjectDir = "主工程目录"
    xibUsedArray = Array.new()

    #使用xib必须会用到xib的名字，可能有以下三种方式使用，搜索出来以后就行
    xibUsePattern = /\"#{xibFileClassName}\"/
    xibOtherUsePattern = /NSStringFromClass(#{xibFileClassName}.class)/
    xibThirdUsePattern = /NSStringFromClass(\[#{xibFileClassName} class\])/

    Dir.glob(mainProjectDir + "/**/**/**.{m}").each do |ocmFile|
        next if Dir.exists? ocmFile
            text = File.read(ocmFile)
    
            xibresults = text.scan(xibUsePattern)

            xibresults += text.scan(xibOtherUsePattern)

            xibresults += text.scan(xibThirdUsePattern)

            if(xibresults.count > 0)
                puts("xib used in file" + ocmFile)
                puts(xibresults)
            end
    end
end

def startFind
    xibFiles = findXibs
    for xibFile in xibFiles do
        findCoponentXibUsageInMainPrj(xibFile)
    end
end

startFind
