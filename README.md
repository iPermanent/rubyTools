# rubyTools iOS常用脚本
## 日常使用ruby脚本

### 1.[checkUnusedClassOrMethod.rb](https://github.com/iPermanent/rubyTools/blob/master/checkUnusedClassOrMethod.rb)
检测二进制文件内未使用到的类和方法，不过方法检测不够准确

### 2.[copyImages.rb](https://github.com/iPermanent/rubyTools/blob/master/copyImages.rb) 
在由整体项目向组件化抽离时，使用到的图片的资源统一拷贝

### 3.[createLanguageFile.rb](https://github.com/iPermanent/rubyTools/blob/master/createLanguageFile.rb)
根据excel里的多语言，自动生成iOS的多语言格式文本，请自行根据languages.xlsx 格式和自己的格式进行调整修改

### 4.[findXibUse.rb](https://github.com/iPermanent/rubyTools/blob/master/findXibUse.rb)
查找项目中未使用到的xib文件

### 5.[fixImageAssetName.rb](https://github.com/iPermanent/rubyTools/blob/master/fixImageAssetName.rb)
一键修复imageAsset里，使用的asset名和内部图片名不一致的问题，保持一致性

### 6.[fixImportHeader.rb](https://github.com/iPermanent/rubyTools/blob/master/fixImportHeader.rb)
一键修复不规范的头文件引入问题，如 #import "AFNetworking.h" / #import <AFNetworking.h> => #import <AFNetworking/AFNetworking.h>

### 7.[getDumpImageFiles.rb](https://github.com/iPermanent/rubyTools/blob/master/getDumpImageFiles.rb) 
获取项目里重复的图片（md5实际结果为维度判断）

### 8.[linkmapCompare.rb](https://github.com/iPermanent/rubyTools/blob/master/linkmapCompare.rb)
比较两个linkmap,生成一个json结果文件，内部有各库的大小比较和对应的类大小比较，方便分析app版本升级以后各组件的大小增减问题

### 9.[podlockDependencyParse.rb](https://github.com/iPermanent/rubyTools/blob/master/podlockDependencyParse.rb)
通过Podfile.lock 分析各组件的依赖关系，生成一个可视化依赖关系图
