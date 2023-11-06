.PHONY: test test_extended

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./kv_test.go

test_extended:
	cd tests && env go test -v -timeout 60m -run TestVault ./kv_extended_test.go
