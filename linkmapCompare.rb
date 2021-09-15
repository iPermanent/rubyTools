#用法 ruby linkmapCompare.rb xxx-linkmap.txt yyy-linkmap.txt 即可以同目录下生成一个结果的json文件

require 'json'

class LinkMapParser 
    def buildResultWithSymbols(symbols)
        result = ""
        for symbol in symbols
            result = result + symbol["size"].to_s + "\t" + symbol["file"].split("/")[-1] + "\r\n"
        end

        return result
    end

    def symbolMapFromContent(content)
        symbolMap = Hash.new()

        lines = content.split("\n")

        reachFiles = false
        reachSymbols = false
        reachSections = false

        hasPrintMap = false

        for line in lines
            if line.start_with?("#")
                if line.start_with?("# Object files:")
                    reachFiles = true
                elsif line.start_with?("# Sections:")
                    reachSections = true
                elsif line.start_with?("# Symbols:")
                    reachSymbols = true
                end
            else
                if reachFiles == true && reachSections == false && reachSymbols == false
                    range = line.rindex("]")
                    if range != nil    
                        symModel = Hash.new()
                        symModel["file"] = line[range+1,line.length - range-1]
                        key = line[0,range+1]
                        symbolMap[key] = symModel
                    end
                elsif reachFiles == true && reachSections == true && reachSymbols == true
                    if !hasPrintMap
                        # puts(JSON.pretty_generate(symbolMap).gsub(":", " =>"))
                        hasPrintMap = true
                    end
                    symbolsArray = line.split("\t")
                    if symbolsArray.count == 3
                        fileKeyAndName = symbolsArray[2]
                        #16进制转换
                        size = symbolsArray[1].to_i(16)

                        range = fileKeyAndName.index("]")
                        if range != nil
                            key = fileKeyAndName[0,range+1]
                            symbol = symbolMap[key]
                            if symbol != nil
                                if symbol["size"] == nil
                                    symbol["size"] = 0
                                end
                                symbol["size"] = (size + symbol["size"])
                            else
                                puts(key + "未找到")
                            end
                        end
                    end
                end
            end
        end

        return symbolMap
    end

    def openContent(linkMapPath)
        fileContent = File.read(linkMapPath).unpack('C*').pack('U*')

        puts("开始解析原始linkmap文件...")

        objectString = "# Object files:"
        if !fileContent.include?(objectString)
            puts("link map file 文件有误" + "Obj")
            return
        end

        symbolString = "# Symbols:"
        if !fileContent.include?(symbolString)
            puts("link map file 文件有误" + "Symbol")
            return
        end

        if !fileContent.include?("# Path:")
            puts("link map file 文件有误" + "Path")
            return
        end
        
        symbolMap = symbolMapFromContent(fileContent)

        sortedSymbols = Array.new()

        for key in symbolMap.keys
            sortedSymbols.push(symbolMap[key])
        end

        #根据大小排序
        sortedSymbols = sortedSymbols.sort_by {|hashObj| hashObj["size"]}.reverse

        resultSymbols = buildResultWithSymbols(sortedSymbols)

        puts("解析原始linkmap文件完成...")

        return resultSymbols
    end
end

class LibrarySizeAlaysizer
    def prettyFormatClassResult(oriHash)
        for libName in oriHash.keys
            if libName != " DiffResult"
                libHash = oriHash[libName]
                finalArrayValue = Array.new()
                for clsName in libHash.keys
                    clsHash = libHash[clsName]
                    resultString = ""
                    for resultKey in clsHash.keys
                        resultString = resultString + resultKey + " => " + clsHash[resultKey] + " "
                    end
                    simpleHash = Hash.new
                    simpleHash[clsName] = resultString
                    finalArrayValue.push(simpleHash)
                end
                oriHash[libName] = finalArrayValue
            end 
        end
    end

    def alyTotalSize(sizeHash,versionOld,versionNew)
        diffSizeArray = Array.new()
        for libName in sizeHash.keys
            libDiffSize = 0;
            libOldSize = 0;
            libNewSize = 0;
            for clsName in sizeHash[libName].keys
                diffSize = sizeHash[libName][clsName]["大小差值"]
                oldSize =   sizeHash[libName][clsName][versionOld]
                newSize =   sizeHash[libName][clsName][versionNew]

                libDiffSize += diffSize.to_i
                libOldSize += oldSize.to_i
                libNewSize += newSize.to_i
            end
    
            libHash = Hash.new()
            libHash["组件名"] = libName;
            libHash["原大小"] = libOldSize
            libHash["目前大小"] = libNewSize
            libHash["diffSize"] = libDiffSize
    
            diffSizeArray.push(libHash)
        end
        sizeHash[" DiffResult"] = (diffSizeArray.sort_by {|hashObj| hashObj["diffSize"] }).reverse
    end
    
    def parseAndCompareDatas(firsFileContent,secondFileContent,appVersionString1,appVersionString2)
        versionsHash1 = getAllVersionHash(firsFileContent)
        versionsHash2 = getAllVersionHash(secondFileContent)

        puts("开始比较两个版本linkmap文件各库的大小")
    
        compareResultHash = Hash.new()
    
        for libraryName in versionsHash1.keys
            libraryHash = versionsHash1[libraryName]
            for className in libraryHash.keys
                if  compareResultHash[libraryName] == nil
                    compareResultHash[libraryName] = Hash.new()
                end
    
                if compareResultHash[libraryName][className] == nil
                    compareResultHash[libraryName][className] = Hash.new()
                end 
    
                if versionsHash2[libraryName] == nil
                    versionsHash2[libraryName] = Hash.new()
                end
    
                if versionsHash2[libraryName][className] == nil
                    versionsHash2[libraryName][className] = "0"
                end
    
                libSize1 = versionsHash1[libraryName][className]
    
                libSize2 = versionsHash2[libraryName][className] ? versionsHash2[libraryName][className] : "0"
    
                tmpHash = Hash.new()
                if libSize1 != libSize2
                    tmpHash[appVersionString1] = libSize1
                    tmpHash[appVersionString2] = libSize2
                    # puts(libSize2)
    
                    #计算两者差值
                    size1 = libSize1
                    size2 = libSize2
    
                    tmpHash["大小差值"] = (size2.to_i - size1.to_i).to_s
                    compareResultHash[libraryName][className] = tmpHash
                end
            end
        end
    
        for libraryName in versionsHash2.keys
            libraryHash = versionsHash2[libraryName]
            for className in libraryHash.keys
                if compareResultHash[libraryName] == nil
                    compareResultHash[libraryName] = Hash.new()
                end
    
                if  compareResultHash[libraryName][className] == nil
                    libSize2 = versionsHash2[libraryName][className]
                    
                    tmpHash = Hash.new()
    
                    tmpHash[appVersionString1] = "空"
                    tmpHash[appVersionString2] = libSize2
                    tmpHash["大小差值"] = libSize2
                    compareResultHash[libraryName][className] = tmpHash
                end
            end
        end
    
        removeEmtpyKeys(compareResultHash)
        alyTotalSize(compareResultHash,appVersionString1,appVersionString2)
        prettyFormatClassResult(compareResultHash)
        resultIncreamentText =  JSON.pretty_generate(compareResultHash.sort.to_h) 
    
        resultLogPath = __dir__ + "/libSizeCompareResult.json"
        if !Dir.exists?(resultLogPath)
            File.new(resultLogPath,'w')
        end
        File.open(resultLogPath, "w") do |f|
            f.write(resultIncreamentText)
        end
    
        puts("分析完成，结果已经保存到=>" + resultLogPath)
    
    end
    
    def removeEmtpyKeys(hashObj)
        for libName in hashObj.keys
            libHash = hashObj[libName]
            for clsName in libHash.keys
                versionsHash = hashObj[libName][clsName]
                if versionsHash.keys.count == 0
                    libHash.delete(clsName)
                end
            end
        end
    
        for libName in hashObj.keys
            if hashObj[libName].keys.count == 0
                hashObj.delete(libName)
            end
        end
    end
    
    def prettyPutsHash(hashContent)
        putContent = JSON.pretty_generate(hashContent).gsub(":", " =>")
        puts(putContent)
    end
    
    def mainLibraryName(libName)
        if libName.include?("(")
            return libName.split("(")[0]
        end
        return libName
    end
    
    def libraryClassName(libName)
        if libName.include?("(")
            return libName.split("(")[1].gsub(".o)","")
        end
        return libName
    end
    
    def getAllVersionHash(fileContents)
        hashContents = Hash.new()
    
        lines = fileContents.split("\n")

        for line in lines
            libContents = line.split(" ")
                #前面的库名
                libName = libContents[1].split("(")[0]
                #类名
                className = libraryClassName(libContents[1]) 
                libSize = libContents[0]
    
                if hashContents[libName] == nil
                    classVersionHash = Hash.new()
                    classVersionHash[className] = libSize
                    hashContents[libName] = classVersionHash
                else
                    hashContents[libName][className] = libSize
                end
        end    
        return hashContents
    end
end

parser = LinkMapParser.new
libCompareAly = LibrarySizeAlaysizer.new

linkMapPathFirst = ARGV[0]
linkMapPathSecond = ARGV[1]

libUsageFirst = parser.openContent(linkMapPathFirst)
libUsageSecond = parser.openContent(linkMapPathSecond)

    
appVersionString1 = linkMapPathFirst.split("/")[-1].split("-")[0]
appVersionString2 = linkMapPathSecond.split("/")[-1].split("-")[0]

libCompareAly.parseAndCompareDatas(libUsageFirst,libUsageSecond,appVersionString1,appVersionString2)
