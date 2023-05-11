#!/bin/bash

# if [[ -z "$1" ]]
# then
#  echo "Namespace Environment is needed!"
#  echo "Example: des or prd"
#  exit 1
# fi

# Getting Cluster Namespaces
STORAGE_LIST=$(gsutil ls gs://prd-bv-bkp-velero/backups/ \
                        | grep -e "20210105")


IFS=$'\n'

for STORAGE_NAME in $STORAGE_LIST;
do
      echo "Deleting GCP Storage: $STORAGE_NAME"
      gsutil -m rm -r $STORAGE_NAME
      echo "----------------------------"
done

# NOTE: As part of verifying the existence of objects prior to deletion,
#   ``gsutil rm`` makes ``GET`` requests to Cloud Storage for object metadata.
#   These requests incur network and operations charges.

#   The gsutil rm command removes objects and/or buckets.
#   For example, the command:

#     gsutil rm gs://bucket/subdir/*

#   will remove all objects in gs://bucket/subdir, but not in any of its
#   sub-directories. In contrast:

#     gsutil rm gs://bucket/subdir/**

#   will remove all objects under gs://bucket/subdir or any of its
#   subdirectories.

#   You can also use the -r option to specify recursive object deletion. Thus, for
#   example, either of the following two commands will remove gs://bucket/subdir
#   and all objects and subdirectories under it:

#     gsutil rm gs://bucket/subdir**
#     gsutil rm -r gs://bucket/subdir

#   The -r option will also delete all object versions in the subdirectory for
#   versioning-enabled buckets, whereas the ** command will only delete the live
#   version of each object in the subdirectory.

#   Running gsutil rm -r on a bucket will delete all versions of all objects in
#   the bucket, and then delete the bucket:

#     gsutil rm -r gs://bucket

#   If you want to delete all objects in the bucket, but not the bucket itself,
#   this command will work:

#     gsutil rm gs://bucket/**

#   If you have a large number of objects to remove you might want to use the
#   gsutil -m option, to perform parallel (multi-threaded/multi-processing)
#   removes:

#     gsutil -m rm -r gs://my_bucket/subdir

#   You can pass a list of URLs (one per line) to remove on stdin instead of as
#   command line arguments by using the -I option. This allows you to use gsutil
#   in a pipeline to remove objects identified by a program, such as:

#     some_program | gsutil -m rm -I

#   The contents of stdin can name cloud URLs and wildcards of cloud URLs.

#   Note that gsutil rm will refuse to remove files from the local
#   file system. For example this will fail:

#     gsutil rm *.txt

#   WARNING: Object removal cannot be undone. Cloud Storage is designed to give
#   developers a high amount of flexibility and control over their data, and
#   Google maintains strict controls over the processing and purging of deleted
#   data. If you have concerns that your application software or your users may
#   at some point erroneously delete or replace data, see
#   `Best practices for deleting data
#   <https://cloud.google.com/storage/docs/best-practices#deleting>`_ for ways to
#   protect your data from accidental data deletion.