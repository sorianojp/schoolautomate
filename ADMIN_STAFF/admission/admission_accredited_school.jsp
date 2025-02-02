<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.schaccredited.submit();
}
</script>



<body bgcolor="#D2AE72">
<form name="schaccredited" action="./admission_accredited_school.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.Accredited,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	int j = 0; // used to fill up the page with white boxes to make it apprear better .

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission","admission_accredited_school.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Accredited Schools List",request.getRemoteAddr(),
														"admission_accredited_school.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Accredited accredited = new Accredited();
int iSearchResult = 0;
Vector vRetResult = new Vector();
vRetResult = accredited.viewAllSCH(dbOP,request);
dbOP.cleanUP();

iSearchResult = accredited.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
	<%=accredited.getErrMsg()%></font></p>
	<%
	return;
}

%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          ACCREDITED SCHOOL LIST ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>


<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" ><b><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
        Total Schools : <%=iSearchResult%> - Showing(<%=accredited.strDispRange%>)</font></b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/accredited.defSearchSize;
		if(iSearchResult % accredited.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
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

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder"> 
    <tr> 
      <td width="13%" height="25" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL CODE</strong></font></td>
      <td width="30%" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL NAME</strong></font></td>
      <td width="16%" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL TYPE</strong></font></td>
      <td width="39%" class="thinborder">&nbsp;<font size="1"><strong>ADDRESS</strong></font></td>
    </tr>
    <%

for(int i = 0; i< vRetResult.size(); ++i)
{++j;%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    </tr>
    <%
i = i+4;
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
 <table width="100%" bgcolor="#FFFFFF">
<%
if(j < 15)
for(; j< 15; ++j)
{%>
    <tr>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="21">&nbsp;</td>
    </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  </form>
</body>
</html>
