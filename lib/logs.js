const stdouts = [];

export default (maxLength = 200) => {
  const oldWrite = process.stdout.write.bind(process.stdout);
  
  const disable = () => {
    isModified = false;
    return process.stdout.write = oldWrite;
  };
  
  process.stdout.write = (chunk, encoding, callback) => {
    stdouts.push(Buffer.from(chunk, encoding));
    oldWrite(chunk, encoding, callback);
    if (stdouts.length > maxLength) stdouts.shift();
  };
  
  isModified = true;
  return { disable, isModified };
};

export let isModified = false;
export function logs() {
  return Buffer.concat(stdouts);
}

