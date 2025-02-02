<%@ page language="java" import="utility.*,java.util.Vector,hr.HRPIT" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Service Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
	int iAccessLevel = 2;
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Reports and Statistics-Lighthouse Certification","govt_old_service_rcd_print.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	boolean bolPageBreak = false;
	int i = 0;
	int iSearchResult = 0;
	
	HRPIT hrPIT = new HRPIT();
	Vector vUserInfo = null;
	Vector vRetResult = null;
	
	String strPreviousDesignation = null;
	String strPreviousStatus = null;
	String strPreviousStation = null;
	String strPreviousBranch = null;
	String strPreviouseAbsences = null;	
	String strSchCode = dbOP.getSchoolIndex();
	
	boolean bolIsResigned = false;
		
	vUserInfo = hrPIT.getInfoForOldServiceRecord(dbOP, request);
	if(vUserInfo != null)
		vRetResult = hrPIT.operateOnGovtOldServiceRecord(dbOP, request, 4, (String)vUserInfo.elementAt(0));

	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(17*iMaxRecPerPage);	
		if(vRetResult.size()%(17*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td height="20" align="center">Republic of the Philippines</td>
		</tr>
		<tr>
			<td height="20" align="center">
				<strong><%=(SchoolInformation.getSchoolName(dbOP,true,false)).toUpperCase()%></strong></td>
		</tr>
		<tr>
			<td height="20" align="center"><strong><%=(SchoolInformation.getAddressLine1(dbOP,true,false))%></strong></td>
		</tr>
		<%if(strSchCode.startsWith("PIT")){%>
		<tr>
			<td height="20">FORM NO. CR - 2</td>
		</tr>
		<%}%>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center"><u><strong>S E R V I C E&nbsp;&nbsp;&nbsp;R E C O R D</strong></u></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="5%">Name:</td>
			<td width="15%" class="thinborderBOTTOM"><%=((String)vUserInfo.elementAt(3)).toUpperCase()%></td>
			<td width="15%" class="thinborderBOTTOM" align="center"><%=((String)vUserInfo.elementAt(1)).toUpperCase()%></td>
			<td width="15%" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue((String)vUserInfo.elementAt(2))%></td>
			<td width="50%">(If married woman give also full maiden name)</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
			<td>(Surname)</td>
			<td align="center">(Given Name)</td>
			<td align="center">(Middle Name)</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="5%">Birth: </td>
			<td width="20%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue((String)vUserInfo.elementAt(4), "&nbsp;")%></td>
			<td width="25%" align="center" class="thinborderBOTTOM"><%=WI.getStrValue((String)vUserInfo.elementAt(5), "&nbsp;")%></td>
			<td width="50%">(Date herein should be checked from birth or baptismal</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
			<td align="center">(Date)</td>
			<td align="center">(Place)</td>
			<td> certificate or some other reliable documents.)</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="4"><div align="justify">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				This is to certify that the employee named herein above actually rendered services in this Office 
				as shown by the service record below, each line of which is supported by appointment and 
				other papers actually issued by this Office and approved by the authorities concerned.</div><br></td>
		</tr>
</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="30" align="center" class="thinborder" colspan="2"><strong>SERVICE<br>(Inclusive Dates)</strong></td>
			<td colspan="3" align="center" class="thinborder"><strong>RECORD OF APPOINTMENT</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>OFFICE ENTITY DIVISION</strong></td>
			<td rowspan="2" align="center" class="thinborder" width="8%"><strong>L/V ABS w/o PAY</strong><strong></strong></td>
			<td colspan="2" align="center" class="thinborder"><strong><u>SEPARATION</u><br>4</strong></td>
		</tr>
		<tr>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>From</strong></td>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>To</strong></td>
			<td align="center" class="thinborder" valign="top" width="12%"><strong>Designation</strong></td>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>Status<br><br>1</strong></td>
			<td align="center" class="thinborder" valign="top" width="14%"><strong>Salary<br><br>2</strong></td>
			<td align="center" class="thinborder" valign="top" width="14%"><strong>Station<br>Place of Assignment</strong></td>
			<td align="center" class="thinborder" valign="top" width="10%"><strong>Branch<br><br>3</strong></td>
			<td align="center" class="thinborder" valign="top" width="8%"><strong>Date</strong></td>
			<td align="center" class="thinborder" valign="top" width="10%"><strong>Cause</strong></td>
		</tr>
		<% 
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=25, ++iCount,++iResultCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;	
				bolIsResigned = false;
				if(WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;").toLowerCase().equals("resigned"))
					bolIsResigned = true;		
		%>
		<tr>
			<td height="25" align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+1), "&nbsp;")%></td>
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
				if(strPreviousDesignation != null){
					if(strTemp.equals(strPreviousDesignation))
						strTemp = "-do-";
					else
						strPreviousDesignation = strTemp;
				}
				else
					strPreviousDesignation = strTemp;
			%>
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+8));
				if(strPreviousStatus != null){
					if(strTemp.equals(strPreviousStatus))
						strTemp = "-do-";
					else
						strPreviousStatus = strTemp;
				}
				else
					strPreviousStatus = strTemp;
					
				if(strTemp != null && strTemp.length() > 4)
					strTemp = strTemp.substring(0, 4) + ".";
			%>			
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<td align="right" class="thinborderLEFT">
				<%
				strTemp =WI.getStrValue( (String)vRetResult.elementAt(i+9));
				if(strTemp != null && iCount == 0)
					iCount = 1;
					
				if(iCount==1 && !bolIsResigned){%>
					P&nbsp;&nbsp;
				<%}if(!bolIsResigned) {%>
					<%=WI.getStrValue(CommonUtil.formatFloat(strTemp, true), "&nbsp;")%>
				<%}else{%>&nbsp;<%}%>
			</td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));
				if(strPreviousStation != null){
					if(strTemp.equals(strPreviousStation))
						strTemp = "-do-";
					else
						strPreviousStation = strTemp;
				}
				else
					strPreviousStation = strTemp;
				if(bolIsResigned)
					strTemp = null;
			%>	
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%				
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12));
				if(strPreviousBranch != null){
					if(strTemp.equals(strPreviousBranch))
						strTemp = "-do-";
					else
						strPreviousBranch = strTemp;
				}
				else
					strPreviousBranch = strTemp;
				if(bolIsResigned)
					strTemp = null;
			%>	
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13), "None");
				if(strPreviouseAbsences != null){
					if(strTemp.equals(strPreviouseAbsences))
						strTemp = "-do-";
					else
						strPreviouseAbsences = strTemp;
				}
				else
					strPreviouseAbsences = strTemp;
			%>
			<td align="center" class="thinborderLEFT"><%if(!bolIsResigned) {%><%=strTemp%><%}else{%>&nbsp;<%}%></td>
			<%if((String)vRetResult.elementAt(i+16) != null && (String)vRetResult.elementAt(i+14) == null && (String)vRetResult.elementAt(i+15) == null){%>
				<td align="center" class="thinborderLEFTRIGHT" colspan="2"><%=(String)vRetResult.elementAt(i+16)%></td>
			<%}else{%>
				<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+14), "&nbsp;")%></td>
				<td align="center" class="thinborderLEFTRIGHT"><%=WI.getStrValue((String)vRetResult.elementAt(i+15), "&nbsp;")%></td>
			<%}%>
		</tr>
	<%}%>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2" class="thinborderTOP">&nbsp;</td>
		</tr>
		<tr>
			<%if(strSchCode.startsWith("PIT"))
					strTemp = "Issued in compliance with Executive Order No. 54 , dated August 10, 1964, " +
					"and in accordance with Circular No. 52, dated August 10, 1954, of the System.";
				else
					strTemp = "Issued in compliance with Executive Order No. 545 , dated August 10, 1954, " +
					"and in accordance with Circular No. 58, dated August 10, 1954, of the System.";
			%>
			<td colspan="2"><div align="justify"><%=strTemp%></div>
			<br></td>
		</tr>
		<tr>
			<td height="20" width="60%">&nbsp;</td>
		    <td width="40%">CERTIFIED CORRECT:</td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
		</tr>
		<%if(strSchCode.startsWith("PIT")){%>
		<tr>
			<td height="20" align="center">_______________________________</td>
			<td align="center"><strong>HAIDE O. MARQUEZ</strong></td>
		</tr>
		<tr>
			<td height="20" align="center">Date</td>
			<td align="center">Administrative Office V for HRM</td>
		</tr>
		<%}else{%>
		<tr>
			<td height="20" align="center">&nbsp;</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;<strong><%=WI.fillTextValue("certified_by")%>&nbsp;</strong></td>
		</tr>
		<tr>
			<td height="20"><font size="1"><%=iPageNo%> of <%=iTotalPages%></font></td>
			<td align="center"><%=WI.fillTextValue("cert_position")%></td>
		</tr>		
		<%}%>
</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>