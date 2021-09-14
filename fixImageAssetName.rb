#Author HenryZhang 2021/09/14


#通过路径判断是否为asset下的，取asset名字
def getAssetImageName(imagePath)
    #说明是在asset目录下的
    splitRes = imagePath.split(".imageset/")
    if splitRes.count == 2
      prefixPath = splitRes[0]
      assetPaths = prefixPath.split("/")
      assetName = assetPaths[-1]
  
      return assetName
    end
    
    return ""
end

def getAllNeedFixImages
    #当前路径
    projectName = File.basename(__dir__)
    projectDir = __dir__ + "/" + projectName

    allImages = Array.new()

    #遍历所有格式图片
    puts("需要修复的图片名有")
    Dir.glob(projectDir + "/**/**/**/**/**.{jpg,png,bmp}").each do |imageFilePath|
      next if Dir.exists? imageFilePath
        
      #寻找在asset中的图片
      imageAssetName = getAssetImageName(imageFilePath)
      imageRealtName = imageFilePath.split("/")[-1].split("@")[0]
      #如果asset名和图片实际名字不同，对文件名进行修改
      if imageAssetName.length > 0 and imageRealtName != imageAssetName
        puts("realName: " + imageRealtName)
        puts("assetName: " + imageAssetName)

        #获取目录
        folderPath = File.dirname(imageFilePath)
        #对图片进行重命名
        oldImageFileName = imageFilePath.split("/")[-1]
        newFileName = oldImageFileName.gsub(imageRealtName,imageAssetName)

        newImageFilePath = folderPath + '/' + newFileName
        File.rename(imageFilePath,newImageFilePath)

        #别忘了还有json文件需要修改
        jsonFilePath = folderPath + '/Contents.json'
        jsonContent = File.read(jsonFilePath)

        #需要替换的字符串
        oriString = "\"filename\" : \"" + oldImageFileName + "\""

        puts('原字符串  ' + oriString)

        imgSuffixString = oldImageFileName.include?("@") ? oldImageFileName.split("@")[1] : oldImageFileName

        targetString = "\"filename\" : \"" + imageAssetName + "@" + imgSuffixString + "\""

        puts("需替换的字符串 " + targetString)

        jsonContent = jsonContent.gsub(oriString,targetString)

        #执行json里的图片名修复
        File.open(jsonFilePath, "w") { |file| file.puts jsonContent }
        puts("json文件内容")
        puts(jsonContent)

        puts("重命名完成")

      end
  
    end
end

getAllNeedFixImages()
