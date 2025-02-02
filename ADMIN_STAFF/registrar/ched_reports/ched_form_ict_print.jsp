<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDIctc"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
.body_font{
	font-size:11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
</head>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM ICT","ched_form_ict.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


Vector vRetResult = null;
CHEDIctc cr = new CHEDIctc();

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedICT(dbOP,request,4);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}


String strHardTypeIndex =null;
String[] astrHardTypeIndex = {"WorkStations","Servers","Printers","Accesories"} ;
%>
<body onLoad="window.print();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (strErrMsg != null &&  strErrMsg.length()!=0){%>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
<%}%>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="16%" 
><strong>CHED</strong></td>
    <td width="59%" 
>&nbsp;</td>
    <td width="11%" 
>&nbsp;</td>
    <td width="15%" 
>&nbsp;</td>
  </tr>
  <tr> 
    <td 
><strong>ICT Form No. 1</strong></td>
    <td 
>&nbsp;</td>
    <td
>&nbsp;</td>
    <td 
>&nbsp;</td>
  </tr>
  <tr> 
    <td
 colspan="4"><div align="center"><strong>INFORMATION AND COMMUNICATIONS TECHNOLOGY 
        SURVEY</strong></div></td>
  </tr>
  <tr> 
    <td colspan="2"
>&nbsp;</td>
    <td
>&nbsp;</td>
    <td
>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"
><strong>Unique Institution Identifier :</strong>&nbsp; <%=WI.fillTextValue("unique_id")%></td>
    <td
>Region</td>
    <td class="thinborderALL"
> <%=WI.fillTextValue("region")%></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>Academic Year</td>
    <td class="thinborderALL"><%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%></td>
  </tr>
  <tr> 
    <td height="19"><strong>Name of Institution :</strong> </td>
    <td height="19">&nbsp;<u><%=SchoolInformation.getSchoolName(dbOP,false,false)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
    <td height="19">&nbsp;</td>
    <td height="19">&nbsp;</td>
  </tr>
    <td><font face="Arial, Helvetica, sans-serif"><strong>Type of Institution &nbsp;: </strong></font></td>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
		<% if (WI.fillTextValue("type_institution").equals("1")) 
			strTemp = "X";
			else 
			strTemp = "&nbsp;";%>
          <td width="10%" class="thinborderALL"><div align="center"><%=strTemp%></div></td>
          <td width="30%">&nbsp;&nbsp;Private</td>
		<% if (strTemp.length() == 1) 
			strTemp = "&nbsp;";
			else 
			strTemp = "X";%>

          <td width="10%" class="thinborderALL"><div align="center"><%=strTemp%></div></td>
          <td width="46%">&nbsp;SUCs</td>
        </tr>
      </table></td>
    <td
>&nbsp;</td>
    <td
>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="4" valign="middle">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="4" valign="middle"><font face="Arial, Helvetica, sans-serif"><em>Direction: 
      Please fill in the information complately as you can. Put &quot;X&quot; 
      mark in the box. Do not leave any unanswered or write&quot;NA&quot; if not 
      applicable.</em></font></td>
  </tr>
  <tr> 
    <td colspan="4" valign="middle">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="4" valign="middle"><strong>A. COMPUTER HARDWARE</strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td width="20%" rowspan="3" valign="middle" class="thinborder"> <p><em>Please 
        count the number of units (institutionwide)</em></p>
      <strong></strong></td>
    <td colspan="8" align="center" valign="middle" class="thinborder">Academic 
      Use</td>
    <td colspan="8" class="thinborder"><div align="center">Operations Use<strong> 
        </strong></div></td>
  </tr>
  <tr> 
    <td colspan="4" align="center" valign="middle" class="thinborder"><strong></strong> 
      <div align="center"></div>
      <div align="center">LAN</div></td>
    <td colspan="4" class="thinborder"><div align="center">Stand Alone</div></td>
    <td colspan="4" class="thinborder"> <p align="center">LAN</p></td>
    <td colspan="4" class="thinborder"><div align="center">Stand Alone</div></td>
  </tr>
  <tr> 
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Branded</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Clone</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Branded</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Clone</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Branded</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Clone</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of Branded</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">No. of 
        Clone</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">Source 
        of Funding</font></div></td>
  </tr>
  <% 
	int i = 0;

	boolean bolNewCatg = false;
	String strHardCategory = null;
	String strNumClone = "";
	String strCloneSrc = "";
	String strNumBranded = "";
	String strBrandedSrc = "";

	for (i =0; i < vRetResult.size() ;) {
	if ((String)vRetResult.elementAt(i+5) != null) {
		if (Integer.parseInt((String)vRetResult.elementAt(i+5)) >2) 
			break; // break for accessoriess.. show only pc / server / 
	    
%>
  <tr> 
    <td 
 colspan="17" bgcolor="#E5E5E5" class="thinborder">&nbsp; <strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></td>
  </tr>
  <%
	} // end if classification index not null 
	
	if ((String)vRetResult.elementAt(i+8) == null && 
		 (String)vRetResult.elementAt(i+11) == null)  {// if hardware category has no entry at all
	%>
  <tr> 
    <td 
 class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(i+7)%></td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <%
	i+=14;
	}else{%>
  <tr> 
    <td 
 class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(i+7)%></td>
    <% strHardCategory = (String)vRetResult.elementAt(i+6);
	   strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("0") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("0")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),"");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
    <td class="thinborder">&nbsp;<%=strNumBranded%></td>
    <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
    <td class="thinborder">&nbsp;<%=strNumClone%></td>
    <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
    <% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("0") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("1")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),"");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
    <td class="thinborder">&nbsp;<%=strNumBranded%></td>
    <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
    <td class="thinborder">&nbsp;<%=strNumClone%></td>
    <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
    <% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("1") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("0")){
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),"");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
    <td class="thinborder">&nbsp;<%=strNumBranded%></td>
    <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
    <td class="thinborder">&nbsp;<%=strNumClone%></td>
    <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
    <% strNumClone = "";
	   strCloneSrc = "";
	   strNumBranded = "";
	   strBrandedSrc = "";
	
	if (i < vRetResult.size() && strHardCategory.equals((String)vRetResult.elementAt(i+6)) && 
	    WI.getStrValue((String)vRetResult.elementAt(i+3)).equals("1") && 
		WI.getStrValue((String)vRetResult.elementAt(i+4)).equals("1"))
	{ 
	   strNumClone = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	   strCloneSrc = WI.getStrValue((String)vRetResult.elementAt(i+10));
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),"");
	   strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));	   
	   i+=14;
	}%>
    <td class="thinborder">&nbsp;<%=strNumBranded%></td>
    <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
    <td class="thinborder">&nbsp;<%=strNumClone%></td>
    <td class="thinborder">&nbsp;<%=strCloneSrc%></td>
  </tr>
  <% } // end else if hardware category has no entry at all
	  } // end for loop %>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr> 
    <td width="60%">&nbsp; </td>
    <td width="10%">&nbsp;</td>
    <td width="20%"><strong>B. ICT MANPOWER</strong></td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr> 
    <td valign="top"> <% if (i  < vRetResult.size()) {%> <table cellpadding="0" cellspacing="0" border="0" class="thinborder" width="100%">
        <tr> 
          <td width="25%" class="thinborder"><div align="center"><font size="1"><strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></font></div></td>
          <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>No.</strong></font></div></td>
          <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>Source of Funding</strong></font></div></td>
          <td width="24%" class="thinborder"><div align="center"><font size="1"><strong><%=astrHardTypeIndex[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></strong></font></div></td>
          <td width="8%" class="thinborder"> <div align="center"><font size="1"><strong>No.</strong></font></div></td>
          <td width="16%" class="thinborder"> <div align="center"><font size="1"><strong>Source of Funding</strong></font></div></td>
        </tr>
        <% 
 int iMaxSize = 0;
 int iLeftIndex = ((((vRetResult.size() - i)/14)/2) + (((vRetResult.size() - i)/14)%2))*14 + i;
 // ((( / 14)/2)  + ((vRetResult.size() - i) / 14)%2)) *14 + i;
 
 iMaxSize = iLeftIndex;


 for (; i < iMaxSize; i+=14, iLeftIndex+=14){
		 strHardCategory = (String)vRetResult.elementAt(i+7);
	    strNumBranded = WI.getStrValue((String)vRetResult.elementAt(i+11),"N/A");
		strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(i+13));
 %>
        <tr> 
          <td class="thinborder">&nbsp;<%=strHardCategory%></td>
          <td class="thinborder">&nbsp;<%=strNumBranded%></td>
          <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
          <% if (iLeftIndex <vRetResult.size()) {
 		strHardCategory = (String)vRetResult.elementAt(iLeftIndex+7);	
	   strNumBranded = WI.getStrValue((String)vRetResult.elementAt(iLeftIndex+11),"N/A");
		strBrandedSrc = WI.getStrValue((String)vRetResult.elementAt(iLeftIndex+13));
	}else{
		strHardCategory = "";
		strNumBranded = "";
		strBrandedSrc = "";
	}
 %>
          <td class="thinborder">&nbsp;<%=strHardCategory%></td>
          <td class="thinborder">&nbsp;<%=strNumBranded%></td>
          <td class="thinborder">&nbsp;<%=strBrandedSrc%></td>
        </tr>
        <%}%>
      </table>
      <%} // end if i < vRetResult.size();
 else{%> &nbsp <%}%></td>
    <td>&nbsp;</td>
    <td valign="top"> 
      <% 
if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedICTStaff(dbOP,request,4);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (vRetResult != null && vRetResult.size() > 0) {


	String[] astrEmpTypeIndex = {"Programmers","System Analyst/Designer","LAN Administrator",
								 "Computer /EDP Operator",  "Database Administrator", 
								 "Instructor / Professor"} ;
%>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr> 
          <td width="75%" 
 class="thinborder"><div align="center"><strong>Position</strong></div></td>
          <td width="25%" class="thinborder"><div align="center"><strong>No.</strong></div></td>
        </tr>
        <% 
		String strNumEmp = null;
		int iIndex = 0;
		
		for( i= 0; i <astrEmpTypeIndex.length; i++) {
		if (iIndex  < vRetResult.size() &&  
				i == Integer.parseInt((String)vRetResult.elementAt(iIndex+3))){
			strNumEmp = (String)vRetResult.elementAt(iIndex+4);
			iIndex +=5;
		}else{
			strNumEmp = "N/A";
		}
		if(strNumEmp.equals("0"))
			strNumEmp = "&nbsp;";
	%>
        <tr> 
          <td class="thinborder">&nbsp;<%=astrEmpTypeIndex[i]%></td>
          <td class="thinborder"><div align="center">&nbsp;<%=strNumEmp%></div></td>
        </tr>
        <%}%>
      </table>
      <% } // end if vRetResult %>
    </td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="4" valign="top">&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="4" valign="top"><em>Source of Funding may be presented in codes 
      or acronyms supported by legend on a separate sheet.</em></td>
  </tr>
  <tr> 
    <td colspan="4" valign="top">&nbsp;</td>
  </tr>
</table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%">&nbsp;</td>
      <td colspan="2">Prepared by</td>
      <td colspan="2">Certified Correct</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td rowspan="2">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="48%"><b><%=WI.fillTextValue("prepared_by")%></b></td>
      <td width="5%">&nbsp;</td>
      
    <td width="31%"><b><%=WI.fillTextValue("certified_correct")%></b></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      
    <td><%=WI.fillTextValue("prepare_design")%></td>
      
    <td>&nbsp;</td>
      
    <td><%=WI.fillTextValue("certify_correct")%></td>
    </tr>
  </table>
  <% } // end if vRetResult %>
</body>
</html>
<%
	dbOP.cleanUP();
%>
