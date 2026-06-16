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

import { BreakpointSystem, MediaService, Logger } from 'mediacommon';
import { StyleConstants, BreakpointConstants, SongConstants } from 'constantscommon';
import { Header } from '../components/Header';
import { Player } from '../components/Player';
import { Content } from '../components/ListContent';
import { songList } from '../viewmodel/SongListData';
import { display } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';

const TAG = 'MusicListPage';

@Component
export struct MusicListPage {
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('deviceHeight') deviceHeight: number = 0;
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('isFoldFull') isFoldFull: boolean = false;
  private foldCallback: Callback<display.FoldDisplayMode> = (data: display.FoldDisplayMode) => {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (data === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) {
        this.isFoldFull = true;
      } else {
        this.isFoldFull = false;
      }
    }
  };

  aboutToAppear() {
    AppStorage.setOrCreate('songList', songList);
    MediaService.getInstance();
    this.breakpointSystem.register();
    // 初始化折叠状态
    this.initFoldStatus();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
    // 注销折叠状态监听
    this.unregisterFoldListener();
  }

  /**
   * 初始化折叠状态
   */
  private initFoldStatus(): void {
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        let mode = display.getFoldDisplayMode();
        if (mode === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) {
          this.isFoldFull = true;
        } else {
          this.isFoldFull = false;
        }
        display.on('foldDisplayModeChange', this.foldCallback);
      }
    } catch (exception) {
      Logger.error(TAG, 'Failed to initialize fold status: ' + JSON.stringify(exception));
    }
  }

  /**
   * 注销折叠状态监听
   */
  private unregisterFoldListener(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.off('foldDisplayModeChange', this.foldCallback);
      } catch (error) {
        Logger.error(TAG, `Failed to unregister fold listener: ${JSON.stringify(error)}`);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Header()
        .margin({ top: this.getUIContext().px2vp(this.topRectHeight) })
        .zIndex(2)
      Content()
        .margin({ top: this.getUIContext().px2vp(this.topRectHeight) + (this.isFoldFull ? 50 : 0) })
      Player()
    }
    .width(StyleConstants.FULL_WIDTH)
    .backgroundColor(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
      $r('app.color.page_background_sm') : $r('app.color.page_background_other'))
    .onAreaChange((oldArea: Area, newArea: Area) => {
      if (typeof newArea.height === 'number') {
        this.deviceHeight = newArea.height;
      }
    })
  }

  pageTransition() {
    PageTransitionEnter({ duration: SongConstants.TRANSITION_DURATION, curve: Curve.Smooth, type: RouteType.Pop })
    PageTransitionExit({ duration: SongConstants.TRANSITION_DURATION, curve: Curve.Smooth, type: RouteType.Push })
  }
}