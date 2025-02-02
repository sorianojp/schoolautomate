<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder{
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

</style>
</head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.ApplicationSchedule,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface();
	String strErrMsg = "";
	String strTemp = null;

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
ApplicationSchedule appSch = new ApplicationSchedule();

//collect all the schedule information.
int iSearchResult = 0;
Vector vRetResult = new Vector();
vRetResult = appSch.viewAllSchedule(dbOP,request);
dbOP.cleanUP();

iSearchResult = appSch.iSearchResult;
%>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" colspan="5" bgcolor="#47768F" ><div align="center"><font color="#FFFFFF"></font><strong>::
          ADMISSION SCHEDULES::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>

  <%
 //print if there is any error in getting
 if(vRetResult == null || vRetResult.size() == 0)
 {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="4">
		<%=appSch.getErrMsg()%></font></p>
		<%
		return;
  }
  %>


<table width="100%" bgcolor="#FFFFFF">
    <tr>
      <td width="67%" ><b><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
	  Total Schedules : <%=iSearchResult%> - Showing(<%=appSch.strDispRange%>)</font></b></td>
      <td width="33%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/appSch.defSearchSize;
		if(iSearchResult % appSch.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Jump
          To page: </font>
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
<%
if(vRetResult.size() == 0)//6 in one set ;-)
	return;
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td width="52%" height="25" align="center" class="thinborder"><font size="1"><b>COURSE</b></font></td>
    <td width="9%" align="center" class="thinborder"><font size="1"><b>YEAR</b></font></td>
    <td width="9%" align="center" class="thinborder"><font size="1"><b>SEMESTER</b></font></td>
    <td width="15%" align="center" class="thinborder"><font size="1"><b>START DATE</b></font></td>
    <td width="15%" align="center" class="thinborder"><font size="1"><b>END DATE</b></font></td>
  </tr>
  <%
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","5th Sem","ALL"};
String[] astrConvertYr  = {"ALL","1st","2nd","3rd","4th","5th","6th","7th","8th"};
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
  <tr>
    <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"ALL")%></td>
    <td align="center" class="thinborder"><%=astrConvertYr[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"0"))]%></td>
    <td align="center" class="thinborder"><%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"6"))]%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
  </tr>
  <%
	i = i+6;
}%>
</table>

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr>
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
