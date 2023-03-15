package measurer_test

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestMeasurer(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Measurer Suite")
}
