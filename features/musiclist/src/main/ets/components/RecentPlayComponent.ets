/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BreakpointConstants, StyleConstants, RouterUrlConstants } from 'constantscommon';
import { BreakpointType, SongItem, MediaService, RecentPlayManager } from 'mediacommon';
import { ListAnimationUtils } from '../utils/ListAnimationUtils';

/**
 * 最近播放组件
 * 显示最近播放的歌曲列表
 */
@Component
export struct RecentPlayComponent {
  @Link currentBreakpoint: string;
  @StorageLink('pageIndexInfos') pageIndexInfos: NavPathStack = new NavPathStack();
  @StorageLink('recentPlayRecords') recentPlays: SongItem[] = [];
  
  // 显示的最大数量，0 表示显示全部
  @Prop maxDisplay: number = 0;
  
  // 是否显示标题栏
  @Prop showHeader: boolean = true;
  
  private recentPlayManager: RecentPlayManager = RecentPlayManager.getInstance();

  // ========== 动画相关状态 ==========
  // 歌曲项动画状态：Map<索引, 是否已显示>
  @State songItemVisible: Map<number, boolean> = new Map();
  // 按压状态：Map<索引, 是否按压>
  @State songItemPressed: Map<number, boolean> = new Map();

  aboutToAppear() {
    // 初始化最近播放管理器并加载数据
    this.loadRecentPlays();
  }

  private async loadRecentPlays() {
    await this.recentPlayManager.initialize();
    this.recentPlays = this.recentPlayManager.getRecentPlays();
    AppStorage.setOrCreate('recentPlayRecords', this.recentPlays);
  }

  /**
   * 播放指定歌曲
   */
  private playSong(song: SongItem, index: number) {
    let songList: SongItem[] = AppStorage.get('songList') || [];
    // 找到歌曲在原始列表中的索引
    let originalIndex = songList.findIndex(s => s.id === song.id);
    if (originalIndex !== -1) {
      let mediaService = MediaService.getInstance();
      mediaService.loadAssent(originalIndex);
    }
  }

  /**
   * 获取显示的歌曲列表
   */
  private getDisplaySongs(): SongItem[] {
    if (this.maxDisplay > 0) {
      return this.recentPlays.slice(0, this.maxDisplay);
    }
    return this.recentPlays;
  }

  /**
   * 歌曲项构建器
   */
  @Builder
  SongItemBuilder(song: SongItem, index: number) {
    Row() {
      // 封面图片
      Image(song.label)
        .width(48)
        .height(48)
        .borderRadius(8)
        .margin({ right: 12 })

      // 歌曲信息
      Column() {
        Text(song.title)
          .fontColor(Color.Black)
          .fontSize(new BreakpointType({
            sm: $r('app.float.item_font_sm'),
            md: $r('app.float.item_font_md'),
            lg: $r('app.float.item_font_lg')
          }).getValue(this.currentBreakpoint))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(song.singer)
          .fontColor(Color.Gray)
          .fontSize(new BreakpointType({
            sm: $r('app.float.singer_title_sm'),
            md: $r('app.float.singer_title_md'),
            lg: $r('app.float.singer_title_lg')
          }).getValue(this.currentBreakpoint))
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Blank()

      // 播放按钮
      Image($r('app.media.ic_play'))
        .width(24)
        .height(24)
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(72)
    .padding({
      left: $r('app.float.list_item_padding'),
      right: $r('app.float.list_item_padding')
    })
    .backgroundColor(Color.White)
    // ========== 入场动画 ==========
    .opacity(this.songItemVisible.get(index) ? 1 : 0)
    .translate({ 
      y: this.songItemVisible.get(index) ? 0 : ListAnimationUtils.ENTRANCE_CONFIG.translateY 
    })
    // ========== 按压反馈 ==========
    .scale({ 
      x: this.songItemPressed.get(index) ? ListAnimationUtils.PRESS_CONFIG.scale : 1,
      y: this.songItemPressed.get(index) ? ListAnimationUtils.PRESS_CONFIG.scale : 1
    })
    // ========== 事件处理 ==========
    .onAppear(() => {
      // 触发入场动画
      const delay = ListAnimationUtils.getEntranceDelay(index);
      setTimeout(() => {
        animateTo({
          duration: ListAnimationUtils.ENTRANCE_CONFIG.duration,
          curve: ListAnimationUtils.ENTRANCE_CONFIG.curve
        }, () => {
          this.songItemVisible.set(index, true);
        });
      }, delay);
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        // 按下：缩小
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.songItemPressed.set(index, true);
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        // 抬起/取消：恢复
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.songItemPressed.set(index, false);
        });
        // 点击事件
        if (event.type === TouchType.Up) {
          this.playSong(song, index);
        }
      }
    })
  }

  /**
   * 空状态提示
   */
  @Builder
  EmptyState() {
    Column() {
      Image($r('app.media.ic_album'))
        .width(80)
        .height(80)
        .opacity(0.3)
      
      Text('暂无播放记录')
        .fontColor(Color.Gray)
        .fontSize(16)
        .margin({ top: 16 })
      
      Text('播放歌曲后将在这里显示')
        .fontColor(Color.Gray)
        .fontSize(14)
        .opacity(0.7)
        .margin({ top: 8 })
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 标题栏
      if (this.showHeader) {
        Row() {
          Text('最近播放')
            .fontColor(Color.Black)
            .fontSize(new BreakpointType({
              sm: $r('app.float.play_font_sm'),
              md: $r('app.float.play_font_md'),
              lg: $r('app.float.play_font_lg')
            }).getValue(this.currentBreakpoint))
            .fontWeight(FontWeight.Bold)

          Blank()

          if (this.maxDisplay > 0 && this.recentPlays.length > this.maxDisplay) {
            // 更多按钮
            Row() {
              Text('更多')
                .fontColor($r('app.color.button_background_color'))
                .fontSize(14)
              
              Image($r('app.media.ic_public_forward'))
                .width(16)
                .height(16)
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.pageIndexInfos.pushPathByName(RouterUrlConstants.RECENT_PLAY, null);
            })
          } else if (this.recentPlays.length > 0) {
            Text(`${this.recentPlays.length} 首`)
              .fontColor(Color.Gray)
              .fontSize(new BreakpointType({
                sm: $r('app.float.singer_title_sm'),
                md: $r('app.float.singer_title_md'),
                lg: $r('app.float.singer_title_lg')
              }).getValue(this.currentBreakpoint))
          }
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(56)
        .padding({
          left: $r('app.float.list_item_padding'),
          right: $r('app.float.list_item_padding')
        })
        .backgroundColor(Color.White)
      }

      // 歌曲列表
      if (this.recentPlays.length === 0) {
        this.EmptyState()
      } else {
        List() {
          ForEach(this.getDisplaySongs(), (song: SongItem, index: number) => {
            ListItem() {
              this.SongItemBuilder(song, index)
            }
          }, (song: SongItem, index?: number) => `${song.id}_${index}`)
        }
        .width(StyleConstants.FULL_WIDTH)
        .backgroundColor('#F5F5F5')
        .layoutWeight(1)
        .divider({
          color: $r('app.color.list_divider_color'),
          strokeWidth: $r('app.float.list_stroke_width'),
          startMargin: $r('app.float.list_item_padding'),
          endMargin: $r('app.float.list_item_padding')
        })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(this.maxDisplay > 0 ? undefined : StyleConstants.FULL_HEIGHT)
    .backgroundColor('#F5F5F5')
  }
}
