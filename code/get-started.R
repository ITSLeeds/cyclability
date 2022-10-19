x = 1:9
y = exp(x)
plot(x, y)
class(x)
d = data.frame(x, y)
d
View(d)

u = "https://github.com/ITSLeeds/cyclability/archive/refs/heads/main.zip"
f = basename(u)
f
download.file(url = u, destfile = f)
unzip(zipfile = f)

