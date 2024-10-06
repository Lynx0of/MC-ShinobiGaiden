<?php
// Path to the file you want to zip
$file = 'path/to/ShinobiGaiden-Main-Resources'; 
$zipFile = 'path/to/ShinobiGaiden-Main-Resources.zip';

// Create new Zip archive
$zip = new ZipArchive();
if ($zip->open($zipFile, ZipArchive::CREATE) === TRUE) {
    // Add file to the archive
    $zip->addFile($file, basename($file));
    $zip->close();

    // Set headers to force download the zip file
    header('Content-Type: application/zip');
    header('Content-disposition: attachment; filename='.basename($zipFile));
    header('Content-Length: ' . filesize($zipFile));
    readfile($zipFile);

    // Optionally, you can delete the zip after download
    unlink($zipFile);
} else {
    echo 'Failed to create zip file';
}
?>
