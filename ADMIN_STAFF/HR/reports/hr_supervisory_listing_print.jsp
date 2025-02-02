<%@ page language="java" import="utility.*,hr.HRStatsReports,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee With Leaves</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}

	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script> 

<body onLoad="window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolHasTeam = false;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp with Leaves","hr_supervisory_listing.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"hr_supervisory_listing.jsp");	
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

int iSearchResult = 0;
boolean bolShowHeader = true; 	
int iFieldCount = 30;
int iNumRec = 0; 
boolean bolPageBreak = false;
HRStatsReports hrStat = new HRStatsReports(request);
String strCurUser = null;
String strNextUser = null;

 vRetResult = hrStat.getSupervisorSubList(dbOP);
 if(vRetResult != null)	{

	int iPage = 1; 
	int iCount = 1;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
  int i = 0;
 for (;iNumRec < vRetResult.size();iPage++){ // OUTERMOST FOR LOOP
%>
<form name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" align="center"><strong>SUPERVISOR LISTING </strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td  width="12%" height="25" align="center"  class="thinborder"><strong><font size="1">EMP 
      ID</font></strong></td>
      <td width="30%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
      <td width="38%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
    </tr>
    <%
		for(; iNumRec < vRetResult.size();){	
			if(bolShowHeader){
				bolShowHeader = false;			
		%>
		<tr>
			<%
				strTemp = WI.formatName((String)vRetResult.elementAt(iNumRec + 21), (String)vRetResult.elementAt(iNumRec + 22), 
																(String)vRetResult.elementAt(iNumRec + 23),4);
			%>
      <td height="25" colspan="4" class="thinborder"><strong>IMMEDIATE HEAD: &nbsp;<%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
		<%}%>
		<%for(; iNumRec < vRetResult.size();){
 			i = iNumRec;
			if(i+iFieldCount+1 < vRetResult.size()){
				if(i == 0){
					strCurUser = WI.getStrValue((String)vRetResult.elementAt(i + 20), "0");		
 				}
				strNextUser = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount+ 20), "0");		
 				
				if(!(strCurUser).equals(strNextUser)){
					bolShowHeader = true;
				} 
			}		
			
	
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
  	} else 
			bolPageBreak = false; 
		 %>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <%if(vRetResult.elementAt(i + 5) != null) {//outer loop.
	  		  if(vRetResult.elementAt(i + 6) != null) //inner loop.
						strTemp = (String)vRetResult.elementAt(i + 5) + "/ " + (String)vRetResult.elementAt(i + 6);
					else
						strTemp = (String)vRetResult.elementAt(i + 5);					
  		 	}else if(vRetResult.elementAt(i + 6) != null){//outer loop else
				 	strTemp = (String)vRetResult.elementAt(i + 6);
			  }%> 
      <td class="thinborder">&nbsp;<%=strTemp%></td>			 
	    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 14)%></td>
    </tr>
    <%
				iCount++;
     			iNumRec = iNumRec + iFieldCount;  
 				 if(iNumRec < vRetResult.size()){
					 strCurUser = WI.getStrValue((String)vRetResult.elementAt(iNumRec+ 20), "0");
 				 }	 
				 
				if(bolShowHeader){
					break;
				}
			}//end of for loop to display employee information.
			
			if(bolPageBreak){
				iCount = 1;
				bolShowHeader = true;
				break;
			}
		 }// supervisor %>
  </table>
  <%if (bolPageBreak){			
	%>
<DIV style="page-break-before:always">&nbsp;</Div>
  <%}//page break ony if it is not last page.
   } //end for (iNumRec < vRetResult.size() // END OUTERMOST FOR LOOP
 } //end end upper most if (vRetResult !=null)%>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>