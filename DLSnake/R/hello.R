#install.packages(beepr)
library(beepr)
# 初始化环境变量
init<-function(){
  e<<-new.env()

  e$stage<-0 #场景
  e$width<-e$height<-20  #切分格子
  e$step<-1/e$width #步长
  e$m<-matrix(rep(0,e$width*e$height),nrow=e$width)  #点矩阵
  e$dir<-e$lastd<-'up' # 移动方向
  e$head<-c(2,2) #初始蛇头
  e$lastx<-e$lasty<-2 # 初始化蛇头的位置
  e$tail<-data.frame(x=c(),y=c()) #初始蛇尾

  e$col_bla<-1  # 定义障碍物颜色为黑色

  e$col_furit<-2 # 水果颜色
  e$col_head<-4 # 蛇头颜色
  e$col_tail<-8 # 蛇尾颜色
  e$col_path<-0 # 路颜色
  e$eat_num<-0 # 增加定义“连续吃果子次数”

  e$bla<-c(11, 11)  # 初始化黑色障碍物
  e$bla_lastx<-e$bla_lasty<-11  # 初始化黑色障碍物位置
  e$bla_A=1  # 控制方向
  e$bla_B=11
}


index<-function(col) which(e$m==col)

stage1<-function(){
  e$stage<-1

  # 随机的水果点
  furit<-function(){
    if(length(index(e$col_furit))<=0){ #不存在水果
      idx<-sample(index(e$col_path),1)

      fx<-ifelse(idx%%e$width==0,10,idx%%e$width)
      fy<-ceiling(idx/e$height)
      e$m[fx,fy]<-e$col_furit

      print(paste("furit idx",idx))
      print(paste("furit axis:",fx,fy))
    }
  }
  bla<-function(){
    e$bla_lastx<-e$bla[1]  # 记录障碍物原来位置
    e$bla_lasty<-e$bla[2]
    e$bla[1]<-e$bla[1]-e$bla_A  # 位置移动
    e$bla[2]<-e$bla_B

    if(e$m[e$bla[1], e$bla[2]] == e$col_furit){
      e$bla[1] = e$bla[1] -1
    }  # 判断是否碰到果子
    if(e$bla[1] == 1 | e$bla[1] == 20) {
      e$bla_A=e$bla_A * -1  # 朝着反方向
    }
    if(e$bla[2] == 11) {
      e$bla_B=e$bla_B
    }
  }
  # 检查失败
  fail<-function(){
    # head出边界

    if(length(which(e$head < 1))>0 | length(which(e$head > e$width))>0){
      print("game over: Out of ledge.")
      keydown('q')
      return(TRUE)
    }

    # head碰到tail
    if(e$m[e$head[1],e$head[2]]==e$col_tail){
      print("game over: head hit tail")
      keydown('q')
      beep(1)
      return(TRUE)
    }

    if(e$m[e$bla[1], e$bla[2]] == e$col_tail){
      print("game over: head hit black")
      keydown('q')
      beep(1)
      return(TRUE)
    }

    if(e$head[1] == e$bla[1] & e$head[2]==e$bla[2]){  # 添加碰到黑色障碍物也会结束游戏
      print("game over: head hit black")
      keydown('q')
      beep(1)
      return(TRUE)
    }
    if(nrow(e$tail)>0){

    }

    return(FALSE)
  }


  # snake head
  head<-function(){
    e$lastx<-e$head[1]
    e$lasty<-e$head[2]

    # 方向操作
    if(e$dir=='up') e$head[2]<-e$head[2]+1
    if(e$dir=='down') e$head[2]<-e$head[2]-1
    if(e$dir=='left') e$head[1]<-e$head[1]-1
    if(e$dir=='right') e$head[1]<-e$head[1]+1

  }

  # snake body
  body<-function(){
    e$m[e$lastx,e$lasty]<-0
    e$m[e$bla_lastx, e$bla_lasty]<-0
    e$m[e$bla[1],e$bla[2]]<-e$col_bla
    e$m[e$head[1],e$head[2]]<-e$col_head #snake
    print(data.frame(x=e$lastx,y=e$lasty))
    if(e$eat_num == 3){# e$eat_num表示连吃果子数，连续吃三次果子
      e$tail<-rbind(e$tail,data.frame(x=e$lastx,y=e$lasty))  # 矩阵合并,增加节数
      e$eat_num<-0  # 重置吃果子数
    }
    if(length(index(e$col_furit))<=0){ #不存在水果
      e$tail<-rbind(e$tail,data.frame(x=e$lastx,y=e$lasty))  # 矩阵合并
      beep(1)  # 播放声音，调用的是beepr包的声音函数
      e$eat_num<-e$eat_num+1
    }


    if(nrow(e$tail)>0) { #如果有尾巴
      e$tail<-rbind(e$tail,data.frame(x=e$lastx,y=e$lasty))
      e$m[e$tail[1,]$x,e$tail[1,]$y]<-e$col_path
      e$tail<-e$tail[-1,]
      e$m[e$lastx,e$lasty]<-e$col_tail
    }

    print(paste("snake idx",index(e$col_head)))
    print(paste("snake axis:",e$head[1],e$head[2]))
  }

  # 画布背景
  drawTable<-function(){
    plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
  }

  # 根据矩阵画数据
  drawMatrix<-function(){
    idx<-which(e$m>0)
    px<- (ifelse(idx%%e$width==0,e$width,idx%%e$width)-1)/e$width+e$step/2
    py<- (ceiling(idx/e$height)-1)/e$height+e$step/2
    pxy<-data.frame(x=px,y=py,col=e$m[idx])
    points(pxy$x,pxy$y,col=pxy$col,pch=15,cex=4.4)
    text(0.5,0.5,label=paste("当前得分",nrow(e$tail)),cex=2,col=2)
    # 添加当前得分，使得分在画面中实时显示
  }

  furit()
  bla()
  head()
  if(!fail()){
    body()
    drawTable()
    drawMatrix()
  }
}


# 开机画图
stage0<-function(){
  e$stage<-0
  plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
  text(0.5,0.7,label="Snake Game",cex=5)
  text(0.5,0.4,label="Any keyboard to start",cex=2,col=4)
  text(0.5,0.3,label="Up,Down,Left,Rigth to control direction",cex=2,col=2)
  text(0.2,0.05,label="Author:DanZhang",cex=1)
  text(0.5,0.05,label="http://blog.fens.me",cex=1)
}

# 结束画图
stage2<-function(){
  e$stage<-2
  plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
  text(0.5,0.7,label="Game Over",cex=5)
  text(0.5,0.4,label="Space to restart, q to quit.",cex=2,col=4)
  text(0.5,0.3,label=paste("Congratulations! You have eat",nrow(e$tail),"fruits!"),cex=2,col=2)
  text(0.2,0.05,label="Author:DanZhang",cex=1)
  text(0.5,0.05,label="http://blog.fens.me",cex=1)
}

# 暂停画面
stage3<-function() {
  e$stage<-3
  plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
  text(0.5,0.6,label="游戏已暂停",cex=5)
  text(0.5,0.3,label=paste("Congratulations! You have eat",nrow(e$tail),"fruits!"),cex=2,col=2)
  text(0.2,0.05,label="DuanLang",cex=1)
  text(0.5,0.05,label="https://github.com/duan-LONG",cex=1)
}

# 键盘事件
keydown<-function(K){
  print(paste("keydown:",K,",stage:",e$stage));

  if(e$stage==3) {# 在暂停画面中
    if(K == "q"){
      stage2()  # 如果按下q键就会结束
    }
    if(K == "p"){
      stage1()  # 如果按下p，则会继续进行游戏
    }
    return(NULL)
  }

  if(e$stage==0){ # 开机画面
    init()
    stage1()
    return(NULL)
  }

  if(e$stage==2){ # 结束画面
    if(K=="q") q()
    else if(K==' ') stage0()
    return(NULL)
  }

  if(e$stage==1){ # 在游戏进行中
    if(K == "q") {
      stage2() # 如果按下q键就会结束
    }
    if (K == "p") {
      stage3()  # 如果按下p，则进入暂停画面
    } else {
      if(tolower(K) %in% c("up","down","left","right")){
        e$lastd<-e$dir
        e$dir<-tolower(K)
        stage1()
      }
    }
  }


  return(NULL)
}


run<-function(){
  par(mai=rep(0,4),oma=rep(0,4))
  e<<-new.env()
  stage0()


  getGraphicsEvent(prompt="Snake Game",onKeybd=keydown)
}
x11()
run()
