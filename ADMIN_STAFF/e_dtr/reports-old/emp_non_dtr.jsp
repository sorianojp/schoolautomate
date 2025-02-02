<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	this.SubmitOnce('dtr_op');
}	

function PrintPg() {
	var pgLoc = "./emp_non_dtr_print.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DeleteNonEDTR(strEmpIndex) {
	document.dtr_op.non_EDTR.value = strEmpIndex;
	this.SubmitOnce('dtr_op');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Non DTR Employees",
								"emp_non_dtr.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_non_dtr.jsp");	
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
ReportEDTR RE = new ReportEDTR(request);
eDTR.WorkingHour whPersonal = new eDTR.WorkingHour();
	if(WI.fillTextValue("non_EDTR").length() > 0) {
		if(whPersonal.removeNonEDTRWH(dbOP, WI.fillTextValue("non_EDTR"), 
				(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Working hour information removed successfully.";
		else	
			whPersonal.getErrMsg();
	}

vRetResult = RE.getListNonDTREmployees(dbOP,false);//System.out.println(vRetResult);
	
iSearchResult = RE.getSearchCount();
iPageCount = iSearchResult/RE.defSearchSize;
if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
%>
<form action="./emp_non_dtr.jsp" name="dtr_op" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          NON-EDTR EMPLOYEES ::::</strong></font></div></td>
    </tr>
	    <tr>
      <td height="25"><font size=3><strong><%=WI.getStrValue(strErrMsg)%>&nbsp;</strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="58%"><b>Total Requests: <%=iSearchResult%> - Showing(<%=WI.getStrValue(RE.getDisplayRange(),"0")%>)</b></td>
          <td width="39%">
<%
if(iPageCount > 1) {%>
		  Jump To page: 
            <select name="jumpto" onChange="goToNextSearchPage();">
                <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                <option value="<%=i%>" selected><%=i%> of <%=iPageCount%></option>
                <%}else{%>
                <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                <%
					}
			}
			%>
              </select>
<%}//only if iPageCount > 0)%>
			  </td>
            <td width="3%"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" align="right" border="0"></a></td>
        </tr>
      </table> </td>
  </tr>
    <tr> 
      <td>
<hr size="1">
      <br>
        <table width="100%" border="1" cellpadding="3" cellspacing="0">
          <tr> 
            <td colspan="5" bgcolor="#006A6A"><div align="center"><font color="#FFFFFF"><strong>LIST 
                OF NON DTR EMPLOYEES</strong></font></div></td>
          </tr>
          <tr> 
            <td height="30" bgcolor="#EBEBEB"><div align="center"><strong><font size="1">EMPLOYEE 
                ID</font></strong></div></td>
            <td height="30" bgcolor="#EBEBEB"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
            <td height="30" bgcolor="#EBEBEB"><div align="center"><font size="1"><strong>COLLEGE 
                / OFFICE</strong></font></div></td>
            <td bgcolor="#EBEBEB"><div align="center"><font size="1"><strong>EMPLOYEE 
                TYPE </strong></font></div></td>
            <td height="30" bgcolor="#EBEBEB">&nbsp;</td>
          </tr>
          <% if (vRetResult!=null){ 
			for (int i = 0; i < vRetResult.size(); i+=8){
			%>
          <tr> 
            <td width="14%" height="26"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
            <td width="26%" height="26"><font size="1"><%= WI.formatName((String)vRetResult.elementAt(i+2),
												(String)vRetResult.elementAt(i+3),
												(String)vRetResult.elementAt(i+4),4)%></font></td>
            <% strTemp = (String)vRetResult.elementAt(i+5);
			   if (strTemp == null)
			   		strTemp = (String)vRetResult.elementAt(i+6);
				else{
					if ((String)vRetResult.elementAt(i+6)!=null){
						strTemp += " / "  + (String)vRetResult.elementAt(i+6);
					}
				}
			%>
            <td width="26%" height="26"><font size="1"><%=WI.getStrValue(strTemp,"")%></font></td>
            <td width="21%"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
            <td width="13%" height="26">
              <%
		if(iAccessLevel ==2){%>
              <a href='javascript:DeleteNonEDTR("<%=(String)vRetResult.elementAt(i)%>")'> 
              <img src="../../../images/delete.gif" border="0"> </a> 
         <%}%>
            </td>
          </tr>
          <%		}
	}else{%>
          <tr>
            <td colspan="5"><%=RE.getErrMsg()%></td>
          </tr>
          <%  } 
%>
        </table> 	
        
      </td>
  </tr>
  <tr> 
      <td>&nbsp; </td>
  </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>