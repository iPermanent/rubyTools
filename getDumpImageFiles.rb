require 'digest/md5'

def getOverageSizeImages
    projectDir = Dir.getwd
    imageHashs = Hash.new()

    Dir.glob(projectDir + "/**/**/**/**/**/**/**.{jpg,png,bmp}").each do |imageFilePath|
        next if Dir.exists? imageFilePath
        imageFileSize = File.size(imageFilePath)
        #输出大于50K的图片
        if imageFileSize > 50000
            puts(imageFilePath + " 此图片可能需要进行压缩,图片大小：" + String(imageFileSize))
        end

        imagemd5 = Digest::MD5.file(imageFilePath).hexdigest
        imagePath = imageHashs[imagemd5]

        if imagePath
            imageHashs[imagemd5] = imagePath + ',' + imageFilePath
        else
            imageHashs[imagemd5] = imageFilePath
        end
    end

    for imageMd5 in imageHashs.keys
        imagePath = imageHashs[imageMd5]
        if imagePath.split(',').count > 1
            puts("以下图片为重复图片")
            puts(imagePath.split(','))
        end
    end
end

getOverageSizeImages
