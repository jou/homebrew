require 'formula'

class IsoCodes < Formula
  url 'http://ftp.us.debian.org/debian/pool/main/i/iso-codes/iso-codes_3.27.orig.tar.bz2'
  homepage 'http://pkg-isocodes.alioth.debian.org/'
  md5 '297c36b7512990de84307f5b1f90fdea'

  depends_on 'gettext'

  def install
    ENV.append 'PATH', Formula.factory('gettext').bin

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
