@echo off
REM ============================================================
REM OCI Mumbai (ap-mumbai-1) Compute Instance Creation Macro
REM - Region: ap-mumbai-1 (India West Mumbai)
REM - Shape: VM.Standard.A1.Flex (1 OCPU, 6GB)
REM - Image: Ubuntu (ocid1.image.oc1.ap-mumbai-1.aaaaaaaahx6...)
REM - Subnet/Compartment: per --data-raw below
REM
REM IMPORTANT: authorization, opc-request-id, x-date, x-content-sha256
REM are session-bound. Replace them from browser DevTools (Network tab)
REM when re-running, or use OCI CLI for repeatable runs.
REM ============================================================

curl ^"https://iaas.ap-mumbai-1.oraclecloud.com/20160918/instances^" ^
  -H ^"Accept: */*^" ^
  -H ^"Connection: keep-alive^" ^
  -H ^"Content-Type: application/json^" ^
  -H ^"Origin: https://cloud.oracle.com^" ^
  -H ^"Referer: https://cloud.oracle.com/^" ^
  -H ^"Sec-Fetch-Dest: empty^" ^
  -H ^"Sec-Fetch-Mode: cors^" ^
  -H ^"Sec-Fetch-Site: cross-site^" ^
  -H ^"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36^" ^
  -H ^"accept-language: en^" ^
  -H ^"authorization: Signature keyId=^\^"ST^$eyJraWQiOiJhc3dfYm9tXzE3MTc2MTQwNzc4NTQiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJvY2lkMS51c2VyLm9jMS4uYWFhYWFhYWE3dnJ0eWdwZHJpaHQ2cTNkYm50Z3VveGQzNzViZWluNXEzbGhscWk1bnZvN3MyZjV4amhhIiwibWZhX3ZlcmlmaWVkIjoidHJ1ZSIsImlzcyI6ImF1dGhTZXJ2aWNlLm9yYWNsZS5jb20iLCJwdHlwZSI6InVzZXIiLCJzZXNzX2V4cCI6IlRodSwgMTkgRmViIDIwMjYgMTc6MzQ6MTkgVVRDIiwiYXVkIjoib2NpIiwicHN0eXBlIjoibmF0diIsInR0eXBlIjoibG9naW4iLCJleHAiOjE3NzE1MDczMTgsImlhdCI6MTc3MTUwMzcxOCwianRpIjoiNmYxOTIyZGMtOTg3OC00NzFlLWE0NjgtZDEzZDgwODgwYjM2IiwidGVuYW50Ijoib2NpZDEudGVuYW5jeS5vYzEuLmFhYWFhYWFhdzJ0aTdiY2R1NWEzemN1Z3YzY3o0Zmg1cHFtdXJueGtzNG5hZ2F5aHhoNnp2NHdmcnJ1cSIsImp3ayI6IntcImFsZ1wiOlwiUlMyNTZcIixcImVcIjpcIkFRQUJcIixcImV4dFwiOnRydWUsXCJrZXlfb3BzXCI6W1widmVyaWZ5XCJdLFwia3R5XCI6XCJSU0FcIixcIm5cIjpcIjJEaloxUC0xNHJ2MTFmNXFRd040ZXRZMFE3UlVCUmdWTHg0V2VOMlcxLWVPZGk2bzFtM3lVTHZIWHl4SzRvSkUzMTBwdmgxREFvLXRHVjN4aEg1RTE3YkpqRWhsdXFMMGxrLTUxMEItSVB4Z0REMlZtZ0xvN2VBWDlkRlF2MHNZQU9kYk5qeDkzV29ETTZabEhVU2pRa0liS1ZQWVFRdzgtaFRoSnR4bkpjck5QMEhXZ0VVMHVaTEJaVXk5ejZfaktQa1ZmSlU4QnQ4YVRPa1MzX2xtRU9PREdLNHNkSGxEc3N3Rl9GNE92eHJqOFdXY2Y3cXIwbXZsbWM2dTh5bXRVZUhEMUE1d25PYVRzd3B5T09TVTNYZjdaenpyVmtYb19USF9hSWVESno2VnVtWVBlcDgxdkVsU2h5NHNuUnNoM3BkbTI4aThBbUhCODFvcnJvOG5kUVwiLFwia2lkXCI6XCJwdWJrZXktYTJiMWU4NTAtZGIyYS00N2RjLThmZmYtOWFjZWEwZjNlYWI0XCJ9In0.Z8oE2JCfs2TSHEViHwnGCujMHGNz52ma1JpcYzGI15MFb_E3PC0duqv_KVEZ9aFyc0EvHIIpIie51P9CtdBu8NIAU8M86RRuKdhtSLQpsqp0KbcwW6whIJUpZlr3RntY_mrwgO7-89H0p_h0C8d34OFIGewy4a6XGAKAm41LntC3MfujROORoEs6pJ4YC3u8SPRG-IJCSV2yu1UIBuABKYgEgKAmdH-psXzB7igqLjFgIffnBJ7Thqp-btl37k6N0OF_1WFRztasztWDg1u8SKU_G5A3XE_Q-U-KAuc7fYcB8Yr4rAyY3KfNdPHQ540WW5iAvbs8X6NGnoUzuOp_0Q^\^",version=^\^"1^\^",algorithm=^\^"rsa-sha256^\^",headers=^\^"(request-target) host content-length accept-language content-type opc-request-id x-content-sha256 x-date^\^",signature=^\^"1ctpcYLU8YGcUuxAERioMaA0yfCjE2wnp8454NGuWFGNdtRYeD50fQyU/IdYrjbhgFB9ma6bzGn14aisQ0eQKzA7in9eF+t3AN9zsj4ZtEjNvAg+DtFgM+ODttH3Lv3dcMqXH69L1PnwAEIs7te5Gs23JFYfiJ5yY3w2OvjUUjqlQv2Lvo0Tkfffz/veHrPv7flS659soDZENkI8kNf/UsLrWTljEZ98guT2AC4CQCF9fgQ0rjEwSIkxzHjdyj7cJntSqqfLqqF8I/h/eIKU5mVqtkn/ymbib4TV4e6XqUKqvompWkPbOtW1za3sbQQ+vQADN1syECO/Mj4IYtHKog==^\^"^" ^
  -H ^"opc-request-id: csid66488e4546e284fe3bda35b1aaea/58749a1ae13449d0a6d15ca595e7801f^" ^
  -H ^"sec-ch-ua: ^\^"Not(A:Brand^\^";v=^\^"8^\^", ^\^"Chromium^\^";v=^\^"144^\^", ^\^"Google Chrome^\^";v=^\^"144^\^"^" ^
  -H ^"sec-ch-ua-mobile: ?0^" ^
  -H ^"sec-ch-ua-platform: ^\^"Windows^\^"^" ^
  -H ^"x-content-sha256: awdLyi4RaGAwsdg0BvQ/DQPWi6LB3ekWYzjcNVhhJNs=^" ^
  -H ^"x-date: Thu, 19 Feb 2026 12:33:19 GMT^" ^
  --data-raw ^"^{^\^"availabilityDomain^\^":^\^"uzFR:AP-MUMBAI-1-AD-1^\^",^\^"compartmentId^\^":^\^"ocid1.tenancy.oc1..aaaaaaaaw2ti7bcdu5a3zcugv3cz4fh5pqmurnxks4nagayhxh6zv4wfrruq^\^",^\^"metadata^\^":^{^\^"ssh_authorized_keys^\^":^\^"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUS+FhIcauq4Z2dy04aL6mPqUhWr/Zk8bPoqoWaPae5ZdhuwTU3OTVqCqK4lxVeQNwoQBY1kCFGBS+WAF+EQLMuUBk2FPXGJWBelw5LoyiOKEKV+Cmbc7Fly0Tx1cohZIsyiCNNjG+g3bxNEKvY/6aXGvDUgLxyplbbpj8DWKe40UzSF7UOuzepyFI5D3WO0fNHTcMtOUTW2oYI1L/5MxkFzMPdSmj2rOQrYx/NHqCAKehjcZijPeuGsNWs1yimdF7fMZjRfmW9kVl8dFnaiELWsN7y6rXgpuphvcA8hiSz59QY01CgTzVMsbFv3R6RI1o5cl95kLLp+2jffaX8wwl ssh-key-2026-02-19^\^"^},^\^"displayName^\^":^\^"instance-20260219-2123^\^",^\^"sourceDetails^\^":^{^\^"sourceType^\^":^\^"image^\^",^\^"imageId^\^":^\^"ocid1.image.oc1.ap-mumbai-1.aaaaaaaahx6isbfnp2fekvrp5yrbdir477zejujm3mizwosnxoonhpu2cdwa^\^",^\^"bootVolumeSizeInGBs^\^":100,^\^"bootVolumeVpusPerGB^\^":10^},^\^"shape^\^":^\^"VM.Standard.A1.Flex^\^",^\^"shapeConfig^\^":^{^\^"ocpus^\^":1,^\^"memoryInGBs^\^":6^},^\^"createVnicDetails^\^":^{^\^"assignPublicIp^\^":true,^\^"subnetId^\^":^\^"ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaaogotyo2rzilhgqcumn732knelzlp25fni2xydv7e4hqvs4zmnpoa^\^",^\^"assignPrivateDnsRecord^\^":true,^\^"assignIpv6Ip^\^":false^},^\^"isPvEncryptionInTransitEnabled^\^":true,^\^"instanceOptions^\^":^{^\^"areLegacyImdsEndpointsDisabled^\^":false^},^\^"definedTags^\^":^{^},^\^"freeformTags^\^":^{^},^\^"availabilityConfig^\^":^{^\^"recoveryAction^\^":^\^"RESTORE_INSTANCE^\^"^},^\^"agentConfig^\^":^{^\^"pluginsConfig^\^":^[^{^\^"name^\^":^\^"Vulnerability Scanning^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Management Agent^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Custom Logs Monitoring^\^",^\^"desiredState^\^":^\^"ENABLED^\^"^},^{^\^"name^\^":^\^"Compute RDMA GPU Monitoring^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Compute Instance Monitoring^\^",^\^"desiredState^\^":^\^"ENABLED^\^"^},^{^\^"name^\^":^\^"Compute HPC RDMA Auto-Configuration^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Compute HPC RDMA Authentication^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Cloud Guard Workload Protection^\^",^\^"desiredState^\^":^\^"ENABLED^\^"^},^{^\^"name^\^":^\^"Block Volume Management^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^},^{^\^"name^\^":^\^"Bastion^\^",^\^"desiredState^\^":^\^"DISABLED^\^"^}^],^\^"isMonitoringDisabled^\^":false,^\^"isManagementDisabled^\^":false^}^}^"
