## Post Deployment Destructive Steps

1. Run the destructive changes under the folder build/deploy-scripts/post-manual-steps/post_destructive_changes/src_post_destructive

   sfdx force:mdapi:deploy --testlevel NoTestRun -u {ORGALIAS} -d ./build/deploy-scripts/post-manual-steps/post_destructive_changes/src_post_destructive --ignorewarnings
   
