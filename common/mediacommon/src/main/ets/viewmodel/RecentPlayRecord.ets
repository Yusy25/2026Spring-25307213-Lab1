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

import { SongItem } from './SongData';

/**
 * 最近播放记录数据结构
 * 包含歌曲信息和播放时间戳
 */
export class RecentPlayRecord {
  /**
   * 歌曲ID
   */
  songId: number = 0;

  /**
   * 歌曲标题
   */
  songTitle: string = '';

  /**
   * 歌手名称
   */
  singer: string = '';

  /**
   * 封面资源
   */
  label: Resource = $r('app.string.page_show');

  /**
   * 播放时间戳（毫秒），用于排序
   */
  playTime: number = 0;

  /**
   * 从 SongItem 创建最近播放记录
   */
  static fromSongItem(song: SongItem): RecentPlayRecord {
    let record = new RecentPlayRecord();
    record.songId = song.id;
    record.songTitle = song.title;
    record.singer = song.singer;
    record.label = song.label;
    record.playTime = Date.now();
    return record;
  }

  /**
   * 转换為 SongItem
   */
  toSongItem(): SongItem {
    let song = new SongItem();
    song.id = this.songId;
    song.title = this.songTitle;
    song.singer = this.singer;
    song.label = this.label;
    return song;
  }
}
