#! /usr/bin/python

from socket import AF_INET, AF_INET6, inet_ntop
from ctypes import (
    Structure, Union, POINTER,
    pointer, get_errno, cast,
    c_ushort, c_byte, c_void_p, c_char_p, c_uint, c_int, c_uint16, c_uint32
)
import ctypes.util
import ctypes
import json
import argparse

class struct_sockaddr(Structure):
    _fields_ = [
        ('sa_family', c_ushort),
        ('sa_data', c_byte * 14),]

class struct_sockaddr_in(Structure):
    _fields_ = [
        ('sin_family', c_ushort),
        ('sin_port', c_uint16),
        ('sin_addr', c_byte * 4)]

class struct_sockaddr_in6(Structure):
    _fields_ = [
        ('sin6_family', c_ushort),
        ('sin6_port', c_uint16),
        ('sin6_flowinfo', c_uint32),
        ('sin6_addr', c_byte * 16),
        ('sin6_scope_id', c_uint32)]

class union_ifa_ifu(Union):
    _fields_ = [
        ('ifu_broadaddr', POINTER(struct_sockaddr)),
        ('ifu_dstaddr', POINTER(struct_sockaddr)),]

class struct_ifaddrs(Structure):
    pass
struct_ifaddrs._fields_ = [
    ('ifa_next', POINTER(struct_ifaddrs)),
    ('ifa_name', c_char_p),
    ('ifa_flags', c_uint),
    ('ifa_addr', POINTER(struct_sockaddr)),
    ('ifa_netmask', POINTER(struct_sockaddr)),
    ('ifa_ifu', union_ifa_ifu),
    ('ifa_data', c_void_p),]

libc = ctypes.CDLL(ctypes.util.find_library('c'))

def ifap_iter(ifap):
    ifa = ifap.contents
    while True:
        yield ifa
        if not ifa.ifa_next:
            break
        ifa = ifa.ifa_next.contents

def getfamaddr(sa):
    family = sa.sa_family
    addr = None
    if family == AF_INET:
        sa = cast(pointer(sa), POINTER(struct_sockaddr_in)).contents
        addr = inet_ntop(family, sa.sin_addr)
    elif family == AF_INET6:
        sa = cast(pointer(sa), POINTER(struct_sockaddr_in6)).contents
        addr = inet_ntop(family, sa.sin6_addr)
    return family, addr

class NetworkInterface(object):
    def __init__(self, name):
        self.name = name
        self.index = libc.if_nametoindex(name)
        self.addresses = []
        self.linkstate = None

    def __str__(self):
        return "%s [index=%d, IPv4=%s, IPv6=%s, LinkState=%s]" % (
            self.name, self.index,
            self.addresses.get(AF_INET),
            self.addresses.get(AF_INET6),
            self.linkstate)

class Interfaces(object):
    def __init__(self, data):
        self.data = data

    def get_interface(self, name):
        for item in self.data:
            if item.name == name:
                return item


def get_network_interfaces():
    ifap = POINTER(struct_ifaddrs)()
    result = libc.getifaddrs(pointer(ifap))
    if result != 0:
        raise OSError(get_errno())
    del result
    try:
        retval = {}
        for ifa in ifap_iter(ifap):
            name = ifa.ifa_name
            i = retval.get(name)
            if not i:
                i = retval[name] = NetworkInterface(name)
            family, addr = getfamaddr(ifa.ifa_addr.contents)
            if addr:
                i.addresses.append(addr)
            if bin(ifa.ifa_flags)[2:].rjust(8, "0")[-7] == '1':
                i.linkstate = "UP"
            else:
                i.linkstate = "DOWN"
        return retval.values()
    finally:
        libc.freeifaddrs(ifap)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--iface', default=None)
    parser.add_argument('--state', default=None, action='store_true')
    parser.add_argument('--ip', default=None, action='store_true')

    arguments = parser.parse_args()
    interfaces = Interfaces(get_network_interfaces())
    if arguments.iface:
        interface = interfaces.get_interface(arguments.iface)
        if arguments.state:
            if interface:
                print interface.linkstate
        elif arguments.ip:
            if interface and interface.addresses:
                print interface.addresses[0]
        elif interface:
            print json.dumps(interface.__dict__)
    else:
        print json.dumps({ni.name: ni.__dict__ for ni in interfaces.data})
