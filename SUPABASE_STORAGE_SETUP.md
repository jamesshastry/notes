# Supabase Storage Setup for File Attachments

## 1. Create Storage Bucket

Run this SQL in your Supabase SQL Editor:

```sql
-- Create storage bucket for note attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('note-attachments', 'note-attachments', true);
```

## 2. Update Notes Table Schema

Add the attachments column to your notes table:

```sql
-- Add attachments column to notes table
ALTER TABLE notes ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]';

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_notes_attachments ON notes USING GIN (attachments);
```

## 3. Storage Policies

Set up Row Level Security policies for the storage bucket:

```sql
-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to upload files to their own folder
CREATE POLICY "Users can upload files to their own folder" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'note-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy to allow users to view files in their own folder
CREATE POLICY "Users can view files in their own folder" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'note-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy to allow users to delete files in their own folder
CREATE POLICY "Users can delete files in their own folder" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'note-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy to allow users to update files in their own folder
CREATE POLICY "Users can update files in their own folder" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'note-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
```

## 4. Alternative: Simplified Policies (if auth.uid() doesn't work with Firebase)

If the above policies don't work with Firebase authentication, use these simplified policies:

```sql
-- Simplified policies for Firebase authentication
CREATE POLICY "Allow all operations for authenticated users" ON storage.objects
    FOR ALL USING (true) WITH CHECK (true);
```

## 5. File Structure

Files will be stored in the following structure:
```
note-attachments/
├── {firebase-uid-1}/
│   ├── 1703123456789-abc123def.jpg
│   ├── 1703123456790-def456ghi.pdf
│   └── 1703123456791-ghi789jkl.mp4
├── {firebase-uid-2}/
│   ├── 1703123456792-jkl012mno.docx
│   └── 1703123456793-mno345pqr.zip
└── ...
```

## 6. Supported File Types

The app supports the following file types:
- **Images**: jpg, jpeg, png, gif, webp, svg
- **Videos**: mp4, avi, mov, wmv, webm
- **Documents**: pdf, doc, docx, txt
- **Archives**: zip, rar, 7z
- **Other**: Any file type (with generic icon)

## 7. File Size Limits

Default Supabase Storage limits:
- **Free tier**: 1GB total storage
- **Pro tier**: 100GB total storage
- **File size limit**: 50MB per file

## 8. Testing the Setup

After running the SQL scripts:

1. **Create a note** with file attachments
2. **Check the storage bucket** in Supabase dashboard
3. **Verify file upload** and download functionality
4. **Test file deletion** when deleting notes

## 9. Troubleshooting

### Common Issues:

1. **"Bucket not found" error**:
   - Make sure the bucket `note-attachments` exists
   - Check bucket permissions

2. **"Permission denied" error**:
   - Verify RLS policies are correctly set
   - Check if user is authenticated

3. **"File too large" error**:
   - Check file size limits
   - Consider implementing file compression

4. **"Invalid file type" error**:
   - Check file type restrictions
   - Update accept attribute in HTML input

## 10. Environment Variables

Make sure these environment variables are set in Render:

```
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
```

The app will automatically use Supabase Storage with these credentials.
