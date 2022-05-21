output "vpc_id" {
  value = aws_vpc.o4bproject.id
}

output "public_subnet_id" {
  value = aws_subnet.o4bproject-public.id
}

output "private_subnet_id" {
  value = aws_subnet.o4bproject-private.id
}