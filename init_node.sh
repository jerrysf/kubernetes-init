#!/bin/sh

systemctl stop firewalld
systemctl disable firewalld

swapoff -a 
sed -i 's/.*swap.*/#&/' /etc/fstab

setenforce  0 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux 
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config  

cat <<EOF >> ~/.bashrc
export https_proxy="http://proxy.sin.sap.corp:8080"
export http_proxy="http://proxy.sin.sap.corp:8080"
export no_proxy="10.130.227.241"
echo 1 > /proc/sys/net/ipv4/ip_forward
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y epel-release
yum install -y yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools wget vim  ntpdate libseccomp libtool-ltdl 
yum install -y etcd kubelet kubectl docker kubeadm

systemctl enable ntpdate.service docker kubelet

systemctl daemon-reload

source ~/.bashrc

systemctl start ntpdate.service docker kubelet
 
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc 65536"  >> /etc/security/limits.conf
echo "* hard nproc 65536"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf

mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy.sin.sap.corp:8080"
EOF

systemctl daemon-reload
systemctl restart docker

// Remember to set hostname before join
kubeadm join --token scy4pi.l3c6d89484o8c4bg  --discovery-token-unsafe-skip-ca-verification  10.130.227.241:6443


