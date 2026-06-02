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

import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { SongItem } from '../viewmodel/SongData';
import { RecentPlayRecord } from '../viewmodel/RecentPlayRecord';
import { PreferencesUtil } from './PreferencesUtil';
import { Logger } from './Logger';

const TAG = 'RecentPlayManager';
const RECENT_PLAY_KEY = 'recentPlayRecords';
const DEFAULT_MAX_SIZE = 50;

/**
 * 最近播放记录存储数据接口
 */
interface RecentPlayRecordData {
  songId: number;
  songTitle: string;
  singer: string;
  playTime: number;
}

/**
 * 最近播放管理器
 * 负责管理最近播放记录的存储、读取和更新
 */
export class RecentPlayManager {
  private static instance: RecentPlayManager;
  private context: Context | undefined = AppStorage.get('context');
  private maxSize: number = DEFAULT_MAX_SIZE;
  private recentPlays: RecentPlayRecord[] = [];
  private isInitialized: boolean = false;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): RecentPlayManager {
    if (!RecentPlayManager.instance) {
      RecentPlayManager.instance = new RecentPlayManager();
    }
    return RecentPlayManager.instance;
  }

  /**
   * 设置最大记录数
   */
  public setMaxSize(size: number): void {
    this.maxSize = size;
  }

  /**
   * 初始化，从持久化存储加载最近播放列表
   */
  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    
    try {
      await this.loadFromStorage();
      this.isInitialized = true;
      Logger.info(TAG, `RecentPlayManager initialized with ${this.recentPlays.length} records`);
    } catch (error) {
      Logger.error(TAG, `Failed to initialize: ${(error as BusinessError).message}`);
      this.recentPlays = [];
      this.isInitialized = true;
    }
  }

  /**
   * 从持久化存储加载最近播放列表
   */
  private async loadFromStorage(): Promise<void> {
    if (!this.context) {
      Logger.error(TAG, 'Context is null');
      return;
    }

    try {
      let prefs = await PreferencesUtil.getInstance().getPreferences(this.context);
      let hasKey = await this.hasKey(prefs);
      
      if (hasKey) {
        let value = await this.getRecordsFromPrefs(prefs);
        if (value && Array.isArray(value)) {
          this.recentPlays = this.parseRecords(value);
          // 按播放时间降序排序
          this.sortByPlayTime();
        }
      }
    } catch (error) {
      Logger.error(TAG, `Failed to load from storage: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 检查键是否存在
   */
  private async hasKey(prefs: preferences.Preferences): Promise<boolean> {
    return new Promise((resolve, reject) => {
      prefs.has(RECENT_PLAY_KEY, (err, value) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(value);
      });
    });
  }

  /**
   * 从 Preferences 获取记录
   */
  private async getRecordsFromPrefs(prefs: preferences.Preferences): Promise<preferences.ValueType> {
    return new Promise((resolve, reject) => {
      prefs.get(RECENT_PLAY_KEY, [], (err: BusinessError, value: preferences.ValueType) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(value);
      });
    });
  }

  /**
   * 解析存储的记录
   */
  private parseRecords(value: preferences.ValueType): RecentPlayRecord[] {
    let records: RecentPlayRecord[] = [];
    let arr = value as Array<Record<string, Object>>;
    
    for (let item of arr) {
      let record = new RecentPlayRecord();
      record.songId = (item['songId'] as number) || 0;
      record.songTitle = (item['songTitle'] as string) || '';
      record.singer = (item['singer'] as string) || '';
      record.playTime = (item['playTime'] as number) || 0;
      records.push(record);
    }
    
    return records;
  }

  /**
   * 保存到持久化存储
   */
  private async saveToStorage(): Promise<void> {
    if (!this.context) {
      Logger.error(TAG, 'Context is null');
      return;
    }

    try {
      let prefs = await PreferencesUtil.getInstance().getPreferences(this.context);
      await this.putRecordsToPrefs(prefs);
      PreferencesUtil.getInstance().preferencesFlush(prefs);
      Logger.info(TAG, `Saved ${this.recentPlays.length} records to storage`);
    } catch (error) {
      Logger.error(TAG, `Failed to save to storage: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 将记录写入 Preferences
   */
  private async putRecordsToPrefs(prefs: preferences.Preferences): Promise<void> {
    return new Promise((resolve, reject) => {
      // 转换为可序列化的格式
      let data: RecentPlayRecordData[] = this.recentPlays.map(record => {
        let item: RecentPlayRecordData = {
          songId: record.songId,
          songTitle: record.songTitle,
          singer: record.singer,
          playTime: record.playTime
        };
        return item;
      });
      
      prefs.put(RECENT_PLAY_KEY, data, (err) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });
  }

  /**
   * 按播放时间降序排序
   */
  private sortByPlayTime(): void {
    this.recentPlays.sort((a, b) => b.playTime - a.playTime);
  }

  /**
   * 添加歌曲到最近播放记录
   * 如果已存在，则更新其 playTime 为当前时间并移到最前
   * 否则插入到最前，超出长度则删除最旧
   */
  public async addRecentPlay(song: SongItem): Promise<void> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    // 查找是否已存在
    let existingIndex = this.recentPlays.findIndex(record => record.songId === song.id);
    
    if (existingIndex !== -1) {
      // 已存在，更新播放时间并移到最前
      this.recentPlays[existingIndex].playTime = Date.now();
      // 重新排序
      this.sortByPlayTime();
    } else {
      // 不存在，创建新记录并插入到最前
      let newRecord = RecentPlayRecord.fromSongItem(song);
      this.recentPlays.unshift(newRecord);
      
      // 超出最大长度则删除最旧
      if (this.recentPlays.length > this.maxSize) {
        this.recentPlays = this.recentPlays.slice(0, this.maxSize);
      }
    }

    // 保存到持久化存储
    await this.saveToStorage();
    
    // 更新 AppStorage 以通知 UI 刷新
    AppStorage.setOrCreate('recentPlayRecords', this.getRecentPlays());
    
    Logger.info(TAG, `Added song "${song.title}" to recent plays`);
  }

  /**
   * 获取最近播放歌曲列表（按播放时间降序）
   */
  public getRecentPlays(): SongItem[] {
    return this.recentPlays.map(record => record.toSongItem());
  }

  /**
   * 获取最近播放记录（包含播放时间）
   */
  public getRecentPlayRecords(): RecentPlayRecord[] {
    return [...this.recentPlays];
  }

  /**
   * 获取前 N 首最近播放
   */
  public getTopRecentPlays(count: number): SongItem[] {
    return this.recentPlays.slice(0, count).map(record => record.toSongItem());
  }

  /**
   * 清除所有最近播放记录
   */
  public async clearAll(): Promise<void> {
    this.recentPlays = [];
    await this.saveToStorage();
    AppStorage.setOrCreate('recentPlayRecords', []);
    Logger.info(TAG, 'Cleared all recent play records');
  }

  /**
   * 删除指定歌曲的播放记录
   */
  public async removeBySongId(songId: number): Promise<void> {
    this.recentPlays = this.recentPlays.filter(record => record.songId !== songId);
    await this.saveToStorage();
    AppStorage.setOrCreate('recentPlayRecords', this.getRecentPlays());
    Logger.info(TAG, `Removed song ${songId} from recent plays`);
  }

  /**
   * 获取最近播放数量
   */
  public getCount(): number {
    return this.recentPlays.length;
  }
}
