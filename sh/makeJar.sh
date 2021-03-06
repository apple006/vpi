#! /bin/bash
# mongodb 连接信息
mongodbAddress='120.132.18.250:27017'
mongodbDatabase='github-ams'
mongodbUsername='whcj'
mongodbPassword='LYyVKh7spO7hzDLv'
# 后端接口地址 spring project url prefix
prodApiUrl='http://120.132.18.250:11111'
# 谷歌插件下载地址
chromePluginDownloadUrl='http://www.whcj.press/Vpi-Plugin_v1.0.crx'

# 项目根目录
projectDir='/opt/project/vpi/'
# nginx安装目录/html
nginxHtmlDir='/usr/local/nginx/html/'
# nginx静态文件匹配目录
nginxStaticDir='/opt/uploadFile/'
# jar存放目录
jarSaveDir='/usr/local/'

if  [ "$projectDir" = "" ] ;then
    echo "Missing parameter: projectDir!"
    return
fi
if  [ "$nginxHtmlDir" = "" ] ;then
    echo "Missing parameter: nginxHtmlDir!"
    return
fi
if  [ "$nginxStaticDir" = "" ] ;then
    echo "Missing parameter: nginxStaticDir!"
    return
fi
if  [ "$jarSaveDir" = "" ] ;then
    echo "Missing parameter: jarSaveDir!"
    return
fi

# git pull
cd ${projectDir} || exit
git fetch --all
git reset --hard develop
git pull

# replace parameter
sed -i "s|\$mongodbAddress|${mongodbAddress}|g" ${projectDir}ams/src/main/resources/application-dev.yml
sed -i "s|\$mongodbDatabase|${mongodbDatabase}|g" ${projectDir}ams/src/main/resources/application-dev.yml
sed -i "s|\$mongodbUsername|${mongodbUsername}|g" ${projectDir}ams/src/main/resources/application-dev.yml
sed -i "s|\$mongodbPassword|${mongodbPassword}|g" ${projectDir}ams/src/main/resources/application-dev.yml
sed -i "s|\$prodApiUrl|${prodApiUrl}|g" ${projectDir}front/src/common/js/constant.js
sed -i "s|\$chromePluginDownloadUrl|${chromePluginDownloadUrl}|g" ${projectDir}front/src/common/js/constant.js
sed -i "s|\$prodApiUrl|${prodApiUrl}|g" ${projectDir}front/vue.config.js

# build
cd front || exit
npm install
npm run build
cd ${projectDir}chromePlugin && zip -r vpiChromePlugin.zip ./*
cd ${projectDir}ams && mvn clean package -DskipTests

# close old
appPid=$(netstat -ntlp | grep 11111 | awk '{print $7}' | head -1 | grep '[0-9]\+' -o)
kill -9 "${appPid}"
echo "killed ${appPid}"

# move to nginx file & start
cp ${projectDir}front/dist/index.html ${nginxHtmlDir}
rm -rf ${nginxStaticDir}assets
rm -rf ${nginxStaticDir}static
cp ${projectDir}front/dist/assets ${nginxStaticDir} -r
cp ${projectDir}front/dist/static ${nginxStaticDir} -r
mv ${projectDir}chromePlugin/vpiChromePlugin.zip ${nginxStaticDir}
mv ${projectDir}ams/target/ams.jar ${jarSaveDir}
cd ${jarSaveDir} || exit
nohup java -jar ${jarSaveDir}ams.jar --spring.profiles.active=dev > vpiNohup.out 2>&1 &
tail -f ${jarSaveDir}vpiNohup.out
