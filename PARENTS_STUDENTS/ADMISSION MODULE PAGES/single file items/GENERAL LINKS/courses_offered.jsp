<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.ccourse.submit();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourse,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//end of authenticaion code.

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
CurriculumCourse CC = new CurriculumCourse();
//collect all the schedule information.
int iSearchResult = 0;
Vector vRetResult = null;
vRetResult = CC.viewAll(dbOP,request);

//System.out.println("vRetResult : " + vRetResult);

iSearchResult = CC.iSearchResult;

%>
<form action="./courses_offered.jsp" method="post" name="ccourse">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      COURSES ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">To filter enter course code starts with 
        <input type="text" name="filter_course" value="<%=WI.fillTextValue("filter_course")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH<a href="javascript:goToNextSearchPage();"><img src="../../../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" bgcolor="#FFFFFF">
    <tr> 
      <td width="66%" height="45"><b> Total courses created: <%=iSearchResult%> - Showing(<%=CC.strDispRange%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CC.defSearchSize;
		if(iSearchResult % CC.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="13%" height="25" class="thinborder"><div align="center"><strong><font size="1">COURSE
      CODE </font></strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong><font size="1">COURSE NAME </font></strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong><font size="1">MAJOR</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">CLASSIFICATION</font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">COLLEGE OFFERING</font></strong></div></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    </tr>
    <%
	i = i+9;
}%>
  </table>
 <%}//end of showing if there is course created.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>

<!--
    <tr>
      <td height="25" colspan="8"><font size="1">&nbsp;Click on Specific course to view latest curriculum</font>  </td>
    </tr>
-->
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>