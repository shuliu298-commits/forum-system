// MongoDB 初始化脚本(容器首次启动时由官方 entrypoint 自动执行,mongosh 运行)
// 数据源:同目录 mock-data.json(与 mongoimport 格式一致)
const fs = require('fs');
const path = '/docker-entrypoint-initdb.d/mock-data.json';
const raw = fs.readFileSync(path, 'utf8');
const docs = JSON.parse(raw);

// 将 {$date: "..."} 转换为 BSON Date,保证 LocalDateTime 反序列化正确
const normalize = (doc) => {
  ['createTime', 'updateTime'].forEach((k) => {
    if (doc[k] && doc[k].$date) doc[k] = new Date(doc[k].$date);
  });
  (doc.comments || []).forEach((c) => {
    if (c.createTime && c.createTime.$date) c.createTime = new Date(c.createTime.$date);
  });
  return doc;
};

const result = db.getSiblingDB('forum_content').post.insertMany(docs.map(normalize), { ordered: false });
const count = result.insertedIds ? Object.keys(result.insertedIds).length : docs.length;
print(`[load.js] inserted ${count} posts`);
