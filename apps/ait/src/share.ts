import { setClipboardText } from '@apps-in-toss/web-framework';

export async function shareResult(text: string): Promise<boolean> {
  const value = text.trim();
  if (value.length === 0) return false;

  try {
    await setClipboardText(value);
    return true;
  } catch {
    return false;
  }
}
