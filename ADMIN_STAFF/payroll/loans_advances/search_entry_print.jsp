<%@ page language="java" import="utility.*,payroll.PRLoansAdv,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Loan Search Result</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" src="../../../jscript/common.js"></script>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBottomLeftRight {
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderAll {
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body onLoad="javascript:window.print();">
<form action="search_entry.jsp" method="post" name="form_" id="form_">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-Search","search_entry.jsp");
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
int iSearchResult = 0;
boolean bolPageBreak  = false;

PRLoansAdv searchLoans = new PRLoansAdv(request);
	vRetResult = searchLoans.searchLoansAdvances(dbOP);
%>

  <%	if (vRetResult != null) {	
		int j = 0; int k = 0; int iCount = 0;
		int iMaxRecPerPage =20; 
		
		if (WI.fillTextValue("num_rec_page").length() > 0){
			iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
		}
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="14" colspan="5" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="14" colspan="5" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#FFFFFF" class="thinborderAll"><strong><strong>PAYROLL: 
      ADVANCES/DEDUCTIONS</strong> RESULT </strong></td>
    </tr>
    <tr> 
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="17%" height="28" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
      ID </strong></font></td>
      <td width="37%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
      NAME</strong></font></td>
      <td height="28" align="center" class="thinborder"><font size="1"><strong>TOTAL 
      APPLICATION</strong></font></td>
      <td align="center" class="thinborderBottomLeftRight"><font size="1"><strong>CURRENT 
      BALANCE</strong></font></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8,++iIncr, ++iCount){
		j = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
      <td class="thinborder"><font size="1">&nbsp;<%=iIncr%></font></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j+1)%></td>
      <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(j+2),(String)vRetResult.elementAt(j+4),(String)vRetResult.elementAt(j+3),4).toUpperCase()%></td>
      <td width="18%" height="25" align="center" class="thinborder">      <%=(String)vRetResult.elementAt(j+5)%></td>
      <td width="21%" height="25" align="center" class="thinborderBottomLeftRight"> 
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(j+7),true)%></td>
    </tr>
    <%}// end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td colspan="13"  class="thinborderBottomLeftRight"><div align="center">***************** 
          NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td colspan="13"  class="thinborderBottomLeftRight"><div align="center">************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else%>
  </table>
   <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>