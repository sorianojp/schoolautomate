<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}


-->
</style>
</head>
<script language="JavaScript">
function PrintPg(strUserIndex,strSYFrom,strSYTo,strSem)
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		
		//do not call another page. print this page.
		document.getElementById('myADTable1').deleteRow(0);
		document.getElementById('myADTable1').deleteRow(0);
		
		document.getElementById('myADTable2').deleteRow(0);
		window.print();
		//var pgLoc = "./faculty_detailed_load_print.jsp?ui="+strUserIndex+"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem;
		//var win=window.open(pgLoc,"PrintWindow",'width=700,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		//win.focus();
	}
}
</script>

<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-view load schedule","faculty_detailed_load_view.jsp");
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
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_detailed_load_view.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	FacultyManagement FM = new FacultyManagement();
	Vector vRetResult = null;
	Vector vUserDetail = FM.viewFacultyDetail(dbOP,WI.fillTextValue("ui"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else
	{
		vRetResult = FM.viewFacultyLoadDetail(dbOP,WI.fillTextValue("ui"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		if(vRetResult == null || vRetResult.size() ==0) {
			strErrMsg = FM.getErrMsg();
			vRetResult = null;
		}	
	}
if(strErrMsg == null) strErrMsg = "";
%>


  
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
  <tr bgcolor="#A49A6A">
    <td height="25" colspan="6" bgcolor="#FFFFFF"><a href="javascript:history.back();"><img src="../../../images/go_back.gif" border="0"></a><strong> 
      &nbsp;&nbsp;&nbsp;&nbsp;<%=strErrMsg%></strong></td>
  </tr>
  
  <tr bgcolor="#A49A6A"> 
    <td height="19" colspan="6" bgcolor="#FFFFFF"><hr size="1"></td>
  </tr>
</table>


<%
if(strErrMsg.length() ==0 && vUserDetail != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="30"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,true)%> </div></td>
  </tr>
  <tr>
    <td height="30"><div align="center"><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%><br>
              <%=WI.getStrValue(vUserDetail.elementAt(5))%></strong></div></td>
  </tr>
  <tr>
    <td height="30"><div align="center"><strong> FACULTY LOAD/SCHEDULE<br>
    </strong>School Offering year - <%=request.getParameter("sy_from")%> to <%=request.getParameter("sy_to")%></div></td>
  </tr>
  <tr>
    <td height="10"><div align="center"></div></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td width="47%" height="25">Employee ID: <strong><%=(String)vUserDetail.elementAt(0)%></strong></td>
    <td width="53%">Employee Name : <strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
  </tr>
  <tr>
    <td height="25">Gender : <strong><%=(String)vUserDetail.elementAt(3)%></strong></td>
    <td>Employment Status : <strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
  </tr>
  <tr>
    <td height="25">TOTAL UNITS LOAD : <strong><%=(String)vUserDetail.elementAt(6)%></strong></td>
    <td>&nbsp;</td>
  </tr>
</table>
<% if (vRetResult != null) {%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
  <tr bgcolor="#FFFFFF">
    <td width="34%" height="25"><div align="right"><a href='javascript:PrintPg("<%=request.getParameter("ui")%>","<%=request.getParameter("sy_from")%>","<%=request.getParameter("sy_to")%>",
	  								"<%=request.getParameter("semester")%>");'><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
    to print load/schedule</font></div></td>
  </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="25" colspan="7" align="center" class="thinborder"><strong><font color="#0000FF">LOAD/SCHEDULE 
      DETAIL</font></strong></td>
  </tr>
  <tr> 
    <td align="center" class="thinborder"><font size="1"><strong>MONDAY</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>TUESDAY</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>WEDNESDAY</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>THURSDAY</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>FRIDAY</strong></font></td>
    <td height="25" align="center" class="thinborder"><font size="1"><strong>SATURDAY</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>SUNDAY</strong></font></td>
  </tr>
  <%
	String[] convertAMPM={" am"," pm"};//System.out.println(vRetResult);
for(int i = 0; i< vRetResult.size();){%>
  <tr> 
    <%strTemp = "";
		  while( vRetResult.size() > 0 && ((String)vRetResult.elementAt(i)).compareTo("1") ==0) //this is monday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while( vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("2") ==0) //this is Tuesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("3") ==0) //this is Wednesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("4") ==0) //this is Thursday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("5") ==0) //this is Friday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("6") ==0) //this is Saturday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("0") ==0) //this is Sunday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
  </tr>
  <%
	//i = i+9;
	}%>
</table>
<%
 } // if  no load found (show only personal detail);
} //if error message is null
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>

