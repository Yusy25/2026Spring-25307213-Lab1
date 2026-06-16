/* eslint-disable */
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
import { BreakpointType } from 'mediacommon';
import { SimplePlaylistManager, PlaylistItem } from '../service/SimplePlaylistManager';
import { PlaylistDetailParams } from '../view/PlaylistDetailPage';
import { ListAnimationUtils } from '../utils/ListAnimationUtils';

/**
 * 歌单列表组件
 * 显示所有歌单，支持创建新歌单
 */
@Component
export struct PlayList {
  @Link currentBreakpoint: string;
  @StorageLink('pageIndexInfos') pageIndexInfos: NavPathStack = new NavPathStack();
  
  // 歌单管理器
  private playlistManager: SimplePlaylistManager = SimplePlaylistManager.getInstance();
  
  // 响应式歌单列表
  @State playlists: PlaylistItem[] = [];
  
  // 是否显示创建歌单对话框
  @State showCreateDialog: boolean = false;
  
  // 新歌单名称
  @State newPlaylistName: string = '';

  // ========== 动画相关状态 ==========
  // 歌单项动画状态：Map<索引, 是否已显示>
  @State playlistItemVisible: Map<number, boolean> = new Map();
  // 按压状态：Map<索引, 是否按压>
  @State playlistItemPressed: Map<number, boolean> = new Map();
  // 创建按钮动画状态
  @State createButtonVisible: boolean = false;
  @State createButtonPressed: boolean = false;

  aboutToAppear() {
    // 初始化时加载歌单列表
    this.loadPlaylists();
  }

  /**
   * 加载歌单列表
   */
  private loadPlaylists() {
    this.playlists = this.playlistManager.getPlaylists();
  }

  /**
   * 创建新歌单
   */
  private createNewPlaylist() {
    if (this.newPlaylistName.trim() === '') {
      return;
    }
    
    this.playlistManager.createPlaylist(this.newPlaylistName.trim());
    this.newPlaylistName = '';
    this.showCreateDialog = false;
    
    // 重新加载歌单列表以更新UI
    this.loadPlaylists();
  }

  /**
   * 歌单项构建器
   */
  @Builder
  PlaylistItemBuilder(item: PlaylistItem, index: number) {
    Row() {
      // 歌单图标
      Column() {
        Image($r('app.media.ic_avatar1'))
          .width(48)
          .height(48)
          .borderRadius(8)
      }
      .width(48)
      .height(48)
      .margin({ right: 12 })

      // 歌单信息
      Column() {
        Text(item.name)
          .fontColor(Color.Black)
          .fontSize(new BreakpointType({
            sm: $r('app.float.item_font_sm'),
            md: $r('app.float.item_font_md'),
            lg: $r('app.float.item_font_lg')
          }).getValue(this.currentBreakpoint))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${item.songs.length} 首歌曲`)
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

      // 更多操作按钮
      Image($r('app.media.ic_list_more'))
        .height($r('app.float.order_icon_size'))
        .width($r('app.float.order_icon_size'))
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(72)
    .padding({
      left: $r('app.float.list_item_padding'),
      right: $r('app.float.list_item_padding')
    })
    .backgroundColor(Color.White)
    // ========== 入场动画 ==========
    .opacity(this.playlistItemVisible.get(index) ? 1 : 0)
    .translate({ 
      y: this.playlistItemVisible.get(index) ? 0 : ListAnimationUtils.ENTRANCE_CONFIG.translateY 
    })
    // ========== 按压反馈 ==========
    .scale({ 
      x: this.playlistItemPressed.get(index) ? ListAnimationUtils.PRESS_CONFIG.scale : 1,
      y: this.playlistItemPressed.get(index) ? ListAnimationUtils.PRESS_CONFIG.scale : 1
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
          this.playlistItemVisible.set(index, true);
        });
      }, delay);
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        // 按下：缩小
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.playlistItemPressed.set(index, true);
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        // 抬起/取消：恢复
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.playlistItemPressed.set(index, false);
        });
        // 点击事件
        if (event.type === TouchType.Up) {
          const params: PlaylistDetailParams = {
            playlistId: item.id,
            playlistName: item.name
          };
          this.pageIndexInfos.pushPathByName(RouterUrlConstants.PLAYLIST_DETAIL, params);
        }
      }
    })
  }

  /**
   * 创建歌单按钮
   */
  @Builder
  CreatePlaylistButton() {
    Row() {
      // "+" 图标
      Column() {
        Text('+')
          .fontSize(32)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
      }
      .width(48)
      .height(48)
      .borderRadius(8)
      .backgroundColor('#F0F0F0')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 文字
      Text('创建新歌单')
        .fontColor(Color.Black)
        .fontSize(new BreakpointType({
          sm: $r('app.float.item_font_sm'),
          md: $r('app.float.item_font_md'),
          lg: $r('app.float.item_font_lg')
        }).getValue(this.currentBreakpoint))
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(72)
    .padding({
      left: $r('app.float.list_item_padding'),
      right: $r('app.float.list_item_padding')
    })
    .backgroundColor(Color.White)
    // ========== 入场动画 ==========
    .opacity(this.createButtonVisible ? 1 : 0)
    .translate({ 
      y: this.createButtonVisible ? 0 : ListAnimationUtils.ENTRANCE_CONFIG.translateY 
    })
    // ========== 按压反馈 ==========
    .scale({ 
      x: this.createButtonPressed ? ListAnimationUtils.PRESS_CONFIG.scale : 1,
      y: this.createButtonPressed ? ListAnimationUtils.PRESS_CONFIG.scale : 1
    })
    // ========== 事件处理 ==========
    .onAppear(() => {
      // 创建按钮立即显示（无延迟）
      animateTo({
        duration: ListAnimationUtils.ENTRANCE_CONFIG.duration,
        curve: ListAnimationUtils.ENTRANCE_CONFIG.curve
      }, () => {
        this.createButtonVisible = true;
      });
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.createButtonPressed = true;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({
          duration: ListAnimationUtils.PRESS_CONFIG.duration
        }, () => {
          this.createButtonPressed = false;
        });
        if (event.type === TouchType.Up) {
          this.showCreateDialog = true;
        }
      }
    })
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          Text('我的歌单')
            .fontColor(Color.Black)
            .fontSize(new BreakpointType({
              sm: $r('app.float.play_font_sm'),
              md: $r('app.float.play_font_md'),
              lg: $r('app.float.play_font_lg')
            }).getValue(this.currentBreakpoint))
            .fontWeight(FontWeight.Bold)

          Blank()

          Text(`${this.playlists.length} 个歌单`)
            .fontColor(Color.Gray)
            .fontSize(new BreakpointType({
              sm: $r('app.float.singer_title_sm'),
              md: $r('app.float.singer_title_md'),
              lg: $r('app.float.singer_title_lg')
            }).getValue(this.currentBreakpoint))
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(56)
        .padding({
          left: $r('app.float.list_item_padding'),
          right: $r('app.float.list_item_padding')
        })
        .backgroundColor(Color.White)

        // 歌单列表
        List() {
          // 创建歌单按钮
          ListItem() {
            this.CreatePlaylistButton()
          }

          // 歌单项
          ForEach(this.playlists, (item: PlaylistItem, index: number) => {
            ListItem() {
              this.PlaylistItemBuilder(item, index)
            }
          }, (item: PlaylistItem, index?: number) => item.id.toString())
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
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)

      // 创建歌单对话框
      if (this.showCreateDialog) {
        Column() {
          Column() {
            // 对话框标题
            Text('创建新歌单')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })

            // 输入框
            TextInput({ placeholder: '请输入歌单名称' })
              .width('100%')
              .height(48)
              .onChange((value: string) => {
                this.newPlaylistName = value;
              })
              .margin({ bottom: 20 })

            // 按钮行
            Row() {
              Button('取消')
                .width('45%')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .onClick(() => {
                  this.showCreateDialog = false;
                  this.newPlaylistName = '';
                })

              Blank()

              Button('创建')
                .width('45%')
                .onClick(() => {
                  this.createNewPlaylist();
                })
            }
            .width('100%')
          }
          .width('80%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 100 })  // 距离顶部100vp，避免紧贴顶部
          .onClick(() => {
            // 阻止事件冒泡到背景，不做任何操作
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          // 点击背景关闭对话框
          this.showCreateDialog = false;
          this.newPlaylistName = '';
        })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}
