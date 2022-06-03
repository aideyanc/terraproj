output "vpc_id" {
  value = aws_vpc.o4bproject.id
}

output "public_subnet_id" {
  value = [aws_subnet.o4bproject-public[0].id, aws_subnet.o4bproject-public[1].id]
}

output "private_subnet_id" {
  value = [aws_subnet.o4bproject-private[0].id, aws_subnet.o4bproject-private[1].id]
}