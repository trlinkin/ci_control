class example(
  String $message
){

  file{ '/tmp/example_file':
    content => epp('example/example.epp'),
  }

}
