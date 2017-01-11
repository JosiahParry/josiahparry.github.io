<?php
  include 'parsedown.php';
  $Parsedown = new Parsedown();

  $text = file_get_contents("reddit-tidy-help.md");
  echo $parsedown->text($text);
?>
