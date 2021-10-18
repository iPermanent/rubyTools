require 'roo'

# 打开excel
xlsx = Roo::Spreadsheet.open(Dir.getwd + '/languages.xlsx')

#行数据和列数据
itemColums = xlsx.sheet('Foglio1').row(2)
itemRows = xlsx.sheet('Foglio1').column(2)

#列数因为第一列为空所以从2开始 
$i = 3
$num = itemColums.count()

#第二列的为多语言的key字段
firstColumKeys = xlsx.sheet('Foglio1').column($i - 1)

fileContent = ""
while $i < $num  do
    puts("列数：" + String($i) + "数据为:\n")
    itemColum = xlsx.sheet('Foglio1').column($i)

    #第一列一般为语言名字
    regionName = itemColum[0]

    fileContent = ""
    for key in firstColumKeys
        if key && key.gsub(" ","").length > 0
            index = firstColumKeys.find_index(key)
            value = itemColum[index]
            if !value
                value = ""
            end
            value = value.gsub("\"","")
            rowValue = "\'" + key + "\' = \'" + value + "\'" + ";\n"
            fileContent = fileContent + rowValue
        end    
    end

    puts("保存路径为:\n")
    puts(Dir.getwd + "/" + regionName + ".txt")
    puts("文件内容为：\n")
    puts(fileContent)
    File.open(Dir.getwd + "/" + regionName + ".txt", 'w') { |file| file.write(fileContent) }

    $i +=1
end
