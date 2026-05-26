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

import { BreakpointType, MediaService, SongItem } from 'mediacommon';
import { StyleConstants, BreakpointConstants } from 'constantscommon';
import { SimplePlaylistManager } from '../service/SimplePlaylistManager';
import { songList } from '../viewmodel/SongListData';

/**
 * 歌单详情页面参数
 */
export class PlaylistDetailParams {
  playlistId: number = 0;
  playlistName: string = '';
}

/**
 * 歌单详情页面
 * 显示歌单内的歌曲列表，支持添加歌曲和播放
 */
@Component
export struct PlaylistDetailPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('pageIndexInfos') pageIndexInfos: NavPathStack = new NavPathStack();
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  
  // 页面参数
  @State playlistId: number = 0;
  @State playlistName: string = '';
  
  // 歌单管理器
  private playlistManager: SimplePlaylistManager = SimplePlaylistManager.getInstance();
  
  // 歌曲列表
  @State songs: SongItem[] = [];
  
  // 是否显示添加歌曲对话框
  @State showAddSongDialog: boolean = false;
  
  // 选中的歌曲ID列表
  @State selectedSongIds: number[] = [];

  aboutToAppear() {
    // 从导航参数中获取歌单信息
    const params = this.pageIndexInfos.getParamByIndex(this.pageIndexInfos.size() - 1) as PlaylistDetailParams;
    if (params) {
      this.playlistId = params.playlistId;
      this.playlistName = params.playlistName;
      this.loadSongs();
    }
  }

  /**
   * 加载歌单中的歌曲
   */
  private loadSongs() {
    this.songs = this.playlistManager.getPlaylistSongs(this.playlistId);
  }

  /**
   * 播放歌曲
   */
  private playSong(song: SongItem, index: number) {
    // 将当前歌单的歌曲列表设置为播放列表
    AppStorage.setOrCreate('songList', this.songs);
    
    // 重新初始化 MediaService 以使用新的歌曲列表
    const mediaService = MediaService.getInstance();
    
    // 播放指定索引的歌曲
    mediaService.loadAssent(index);
    
    console.info(`播放歌曲: ${song.title}`);
  }

  /**
   * 切换歌曲选择状态
   */
  private toggleSongSelection(songId: number) {
    const index = this.selectedSongIds.indexOf(songId);
    if (index === -1) {
      this.selectedSongIds.push(songId);
    } else {
      this.selectedSongIds.splice(index, 1);
    }
  }

  /**
   * 添加选中的歌曲到歌单
   */
  private addSelectedSongsToPlaylist() {
    const songsToAdd = songList.filter(song => this.selectedSongIds.includes(song.id));
    const successCount = this.playlistManager.addSongsToPlaylist(this.playlistId, songsToAdd);
    
    console.info(`成功添加 ${successCount} 首歌曲到歌单`);
    
    // 清空选择并关闭对话框
    this.selectedSongIds = [];
    this.showAddSongDialog = false;
    
    // 重新加载歌曲列表
    this.loadSongs();
  }

  /**
   * 歌曲项构建器
   */
  @Builder
  SongItemBuilder(song: SongItem, index: number) {
    Row() {
      // 歌曲封面
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
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Blank()

      // 音质标记
      Image(song.mark)
        .height(20)
        .width(20)
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(72)
    .padding({
      left: $r('app.float.list_item_padding'),
      right: $r('app.float.list_item_padding')
    })
    .backgroundColor(Color.White)
    .onClick(() => {
      this.playSong(song, index);
    })
  }

  /**
   * 空状态提示
   */
  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.ic_avatar1'))
        .width(80)
        .height(80)
        .opacity(0.3)
        .margin({ bottom: 16 })

      Text('歌单暂无歌曲')
        .fontSize(16)
        .fontColor(Color.Gray)
        .margin({ bottom: 8 })

      Text('点击右上角"添加歌曲"按钮')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 添加歌曲对话框
   */
  @Builder
  AddSongDialogBuilder() {
    Column() {
      Column() {
        // 对话框标题
        Row() {
          Text('添加歌曲')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)

          Blank()

          // 关闭按钮
          Text('×')
            .fontSize(28)
            .fontColor(Color.Gray)
            .onClick(() => {
              this.showAddSongDialog = false;
              this.selectedSongIds = [];
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 歌曲列表
        List() {
          ForEach(songList, (song: SongItem) => {
            ListItem() {
              Row() {
                // 复选框
                Checkbox()
                  .select(this.selectedSongIds.includes(song.id))
                  .onChange((isChecked: boolean) => {
                    this.toggleSongSelection(song.id);
                  })
                  .margin({ right: 12 })

                // 歌曲信息
                Column() {
                  Text(song.title)
                    .fontSize(16)
                    .fontColor(Color.Black)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(song.singer)
                    .fontSize(14)
                    .fontColor(Color.Gray)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .height(60)
              .padding({ left: 16, right: 16 })
            }
          }, (song: SongItem) => song.id.toString())
        }
        .width('100%')
        .height(300)
        .divider({
          color: '#F0F0F0',
          strokeWidth: 1
        })
        .margin({ bottom: 16 })

        // 底部按钮
        Row() {
          Text(`已选择 ${this.selectedSongIds.length} 首`)
            .fontSize(14)
            .fontColor(Color.Gray)

          Blank()

          Button('添加')
            .enabled(this.selectedSongIds.length > 0)
            .onClick(() => {
              this.addSelectedSongsToPlaylist();
            })
        }
        .width('100%')
      }
      .width('90%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      // 点击背景关闭对话框
      this.showAddSongDialog = false;
      this.selectedSongIds = [];
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.pageIndexInfos.pop();
            })
            .margin({ right: 16 })

          // 歌单名称
          Text(this.playlistName)
            .fontColor(Color.Black)
            .fontSize(new BreakpointType({
              sm: $r('app.float.play_font_sm'),
              md: $r('app.float.play_font_md'),
              lg: $r('app.float.play_font_lg')
            }).getValue(this.currentBreakpoint))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          // 添加歌曲按钮
          Button('添加歌曲')
            .fontSize(14)
            .height(36)
            .onClick(() => {
              this.showAddSongDialog = true;
            })
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(56)
        .padding({
          left: $r('app.float.list_item_padding'),
          right: $r('app.float.list_item_padding')
        })
        .backgroundColor(Color.White)
        .margin({ top: this.getUIContext().px2vp(this.topRectHeight) })

        // 歌曲列表或空状态
        if (this.songs.length === 0) {
          Column() {
            this.EmptyStateBuilder()
          }
          .width(StyleConstants.FULL_WIDTH)
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.songs, (song: SongItem, index: number) => {
              ListItem() {
                this.SongItemBuilder(song, index)
              }
            }, (song: SongItem, index?: number) => song.id.toString())
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
      .height(StyleConstants.FULL_HEIGHT)

      // 添加歌曲对话框
      if (this.showAddSongDialog) {
        this.AddSongDialogBuilder()
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}
