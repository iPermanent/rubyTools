#!/usr/bin/ruby
# -*- coding: UTF-8 -*-
# author zhangheng 2019-08-21

require 'fileutils'

#查找代码和xib中引用到的图片名
def findUsedImages
    projectName = File.basename(Dir.getwd)
      puts("使用当前脚本的路径")
      projectDir = Dir.getwd + "/" + projectName
  
      imageResults = Array.new()
      Dir.glob(projectDir + "/**/**/**/**.{h,m}").each do |name|
          next if Dir.exists? name
          text = File.read(name)
  
          pattern = /UIImage imageNamed:@"\S+\"/
          results = text.scan(pattern)
          for result in results
            headerSuffix = result.gsub("UIImage imageNamed:@\"","")
            finalImageName = headerSuffix.gsub("\"",""); 
            imageResults.push(finalImageName)
        end
      end
  
      # xibImageResults = Array.new()
      Dir.glob(projectDir + "/**/**/**/**.{xib}").each do |xibname|
        next if Dir.exists? xibname
        text = File.read(xibname)
  
        xibpattern = /image="\S+\"/
        xibresults = text.scan(xibpattern)
        for xibresult in xibresults
          xibprefix = xibresult.gsub("image=\"","")
          xibImageName = xibprefix.gsub("\"",""); 
          imageResults.push(xibImageName)
      end
    end
    uniqImages = imageResults.uniq()
    copyImages(uniqImages)
  end

#通过图片名遍历主工程iamgeAssets
def copyImages(needCopyImageNames)
    mainProjectDir = "对应imageAssets目录"
    Dir.glob(mainProjectDir + "/**/**.{png}").each do |assetName|
      next if Dir.exists? assetName
        dirArr = assetName.split("/")
        dirCount = dirArr.count()
        assetFolderName = dirArr[dirCount - 2]
        # puts("asset名为" + assetFolderName)
      
        needCopyResources = Array.new()
        for imageName in needCopyImageNames
          if assetFolderName.eql? (imageName + ".imageset")
            currentFolderName = File.expand_path("..", assetName)
            needCopyResources.push(currentFolderName)
          end
        end

        #因为2倍图和3倍图都会被遍历到，所以需要做去重处理
        finallyResouces = needCopyResources.uniq()
        destFolderName = Dir.getwd + "/Images.xcassets/"
        for resouceFolder in finallyResouces
          puts("执行copy asset :" + resouceFolder + " => " + destFolderName)
            FileUtils.cp_r(resouceFolder,destFolderName)
        end

      end    
end

findUsedImages
