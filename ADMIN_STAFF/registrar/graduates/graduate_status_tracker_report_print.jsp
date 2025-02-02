<%@ page language="java" import="utility.*,enrollment.GraduateReportSWU,java.util.Vector " %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

body {
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
.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	    DBOperation dbOP= null;
		String strTemp = null;
		String strErrMsg = null;
		WebInterface WI = new WebInterface(request);
		String strImgFileExt = null;
	
	
	  	try{
			dbOP = new DBOperation((String) request.getSession(false).getAttribute("userId"),
				"Admin/staff-Registrar Management-Graduates","graduate_status_tracker_report.jsp");
			ReadPropertyFile readProp = new ReadPropertyFile();
			strImgFileExt = readProp.getImageFileExtn("imgFileUploadExt");
			if(strImgFileExt==null || strImgFileExt.trim().length()==0){
			     strErrMsg ="Image file extension is missing.Please contact school admin.";
				 dbOP.cleanUP();
			}
		}catch(Exception exp){
			exp.printStackTrace();%>
			<p align="center">
				<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				 Error in opening connection
				</font>
			</p>	
	<%	 return;
	    }
	  
	     //authenticate this user.
	     	CommonUtil comUtil = new CommonUtil();
	     	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
	     				"Registrar Management","REPORTS",request.getRemoteAddr(),"graduate_status_tracker_report.jsp");
	     				
	     	if(iAccessLevel == -1)//for fatal error.
	     	{
	     		dbOP.cleanUP();
	     		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	     		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	     		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	     		return;
	     	}
	     	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	     	{
	     		dbOP.cleanUP();
	     		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	     		return;
     	}
	//end of authenticaion code.	
	Vector vRetResult = null;	
	Vector vRecords   = null;
	Vector vEditInfo  = null;
			
	GraduateReportSWU grad = new GraduateReportSWU();
		
	if(WI.fillTextValue("stud_id").length() > 0){
			vRetResult = grad.operateGradStatTrackerReport(dbOP,request,6);
			if(vRetResult == null)
				strErrMsg = grad.getErrMsg();		
			else{
				vRecords = grad.operateGradStatTrackerReport(dbOP, request, 5);	
				if(vRecords == null)
					strErrMsg = grad.getErrMsg();	
			}
	}		
%>
<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%>>
<%if(vRetResult !=null && vRetResult.size()>0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr>
	     <td height="25" style="padding-left:30px;"><strong>GRADUATE STATUS TRACKER REPORT</strong></td>
	 </tr>  
  </table>
         <table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">  
          <tr>
		  	  <td width="30%" align="right" height="25" valign="bottom"><strong>Name</strong>
			  <td colspan="4" valign="bottom">
			  <div style="border-bottom: solid 1px #000000;">
			  <strong><%=(String)vRetResult.elementAt(0)%></strong>
			  </div></td>
			  <td width="1%">&nbsp;</td>
			  <td colspan="2" rowspan="7" valign="top">
			  <img src="../../../../../upload_img/<%=request.getParameter("stud_id")%>.<%=strImgFileExt%>" width="200" height="180"/>
			  </td>
		  </tr>    
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Date of Birth</td>
		      <td colspan="4" valign="bottom">
			  <div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(1))%></strong>
			  </div>
			  </td>
			  <td>&nbsp;</td>
			  
		  </tr>
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Place of Birth</td>
			  <td colspan="4" valign="bottom">
			  <div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong>
			  </div></td>
			  <td>&nbsp;</td>
		  </tr>    
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Blood type</td>
			  <td colspan="4" valign="bottom"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
			  <td>&nbsp;</td>
		  </tr>
		  <tr>
		   	  <td align="right" height="25">Home Address</td>
			  <td colspan="4" valign="bottom"><div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%> 
			  <%=WI.getStrValue((String)vRetResult.elementAt(4),",","","")%>
			  <%=WI.getStrValue((String)vRetResult.elementAt(5),",","","")%>
			  <%=WI.getStrValue((String)vRetResult.elementAt(6),",","","")%>
			  </strong>
			  </div></td>
			  <td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Provincial/Permanent address</td>
			<td colspan="4" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%>
			<%=WI.getStrValue((String)vRetResult.elementAt(4),",","","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(5),",","","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(6),",","","")%>			
			</strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Mobile number</td>
			<td colspan="4" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(7))%></strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  		<td colspan="8" height="25">&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Mother's name</td>		
			<td width="16%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(11))%></strong>
			</div></td> 
			<td width="8%" align="right" valign="bottom">Occupation</td> 
			<td width="12%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(12))%></strong>
			</div></td>
			<td width="10%" align="right" valign="bottom">Contact info</td>
			<td colspan="2" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(13))%></strong>
			</div></td>
			<td width="2%">&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Father's name</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(8))%></strong>
			</div></td>
			<td align="right" valign="bottom">Occupation</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(9))%></strong>
			</div></td>
			<td align="right" valign="bottom">Contact info</td>
			<td colspan="2" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String) vRetResult.elementAt(10))%></strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Spouse's name</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">&nbsp;
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(14))%></strong>
			</div></td>
			<td align="right" valign="bottom">Occupation</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">&nbsp;
			<strong><%//=WI.getStrValue(,"&nbsp;")%></strong>
			</div></td>
			<td valign="bottom" align="right">Contact info</td>
			<td valign="bottom" colspan="2">
			<div style="border-bottom: solid 1px #000000;">&nbsp;
			<strong><%//=WI.getStrValue(,"&nbsp;")%></strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Seafer's Book #</td>
			<% strTemp = WI.fillTextValue("field_1");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			   		strTemp = (String)vEditInfo.elementAt(2);
			%>
			<td colspan="3" valign="bottom">
			<div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Sponsoring Company</td>
			<% strTemp = WI.fillTextValue("field_2");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			  	   strTemp = (String)vEditInfo.elementAt(3);
			%>
			<td colspan="3" valign="bottom">			
			<div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Address</td>
			<%strTemp = WI.fillTextValue("field_3");	
			  if(vEditInfo !=null && vEditInfo.size()>0)
			     strTemp = (String)vEditInfo.elementAt(4);
			%>
			<td colspan="3" valign="bottom">
			<div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>			
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Cadet Agreement</td>
			<td>&nbsp;</td>
			<td align="right" valign="bottom">Embarkation</td>
			<%strTemp = WI.fillTextValue("field_4");
			  if(vEditInfo !=null  && vEditInfo.size()>0)
			     strTemp = (String) vEditInfo.elementAt(5);			
			%>
			<td valign="bottom">			
			<div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			</td>
			<td valign="bottom" align="right">Disembarkation</td>
			<% strTemp = WI.fillTextValue("field_5");
			   if(vEditInfo!=null && vEditInfo.size()>0)
			   		strTemp = (String) vEditInfo.elementAt(6);			
			%>
			<td valign="bottom" colspan="2">
			<div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			</td>
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Change of Sponsoring Company (If applicable)</td>
			 <td colspan="7">&nbsp;</td>		  
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Address</td>
			 <%	strTemp = WI.fillTextValue("field_6");
				if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(7);
			 %>
			 <td valign="bottom" colspan="3">
			 <div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			 </td>
			 <td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Cadet Agreement</td>
			 <td>&nbsp;</td>
			 <td valign="bottom" align="right">Embarkation</td>
			 <%	strTemp = WI.fillTextValue("field_7");
				if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(8);				
			 %>
			 <td valign="bottom"><div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			 </td>
			 <td valign="bottom" align="right">Disembarkation</td>
			 <%strTemp= WI.fillTextValue("field_8");
			   if(vEditInfo!=null && vEditInfo.size()>0)
			   		strTemp  = (String) vEditInfo.elementAt(9);			 
			 %>
			 <td valign="bottom" colspan="2">
			 <div style="border-bottom: solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div> 			
			 </td>
		  </tr>
		  <tr>
		      <td class="8" height="25">&nbsp;</td>
		  </tr>
		  <tr>
	          <td height="25" valign="bottom">SCHOOL INFORMATION</td>
		      <td colspan="7">&nbsp;</td>
		  </tr>	
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Academic Awards</td>
			  <%strTemp= WI.fillTextValue("field_9");
			    if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp=(String) vEditInfo.elementAt(10);			  
			  %>
			  <td colspan="3" valign="bottom">
			  <div style="border-bottom: solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>		  
			  </td>
			  <td colspan="4">&nbsp;</td>
		  </tr>	  
		  <tr>
		  	  <td align="right" valign="bottom" height="25">Awards</td>
			  <%strTemp = WI.fillTextValue("field_10");
			    if(vEditInfo!=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(11);
			  %>
			  <td colspan="3" valign="bottom">
			  <div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			  </td>
			  <td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		     <td align="right" height="25" valign="bottom">LGU Sponsor</td>
			 <%strTemp = WI.fillTextValue("field_11");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			   	  strTemp= (String) vEditInfo.elementAt(12);			 
			 %>
			 <td colspan="3" valign="bottom">
			 <div style="border-bottom:solid 1px #000000;"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></div>
			 </td>
			 <td colspan="4">&nbsp;</td>
		  </tr>
       </table>
	   <br><br><br><br>
	   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	      <tr>
		  	<td height="25"><strong>FOR  SHIPBOARD TRAINING OFFICE USE</strong></td>
		  </tr>
		  <tr>
		  	<td height="25"><strong>BASIC TRAINING AS REQUIRED OF THE STCW CODE</strong></td>
		  </tr>
		  <tr>
		  	<td height="25"><strong><font size="1">As part of your pre-sea training you should have completed Basic Training or instructions as listed. Enter deatils of this training or instruction below.</font></strong></td>
		  </tr>
	   </table>
	   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	   		<tr>
				<td height="25" width="27%" class="thinborder">&nbsp;</td>
				<td width="24%" class="thinborder" align="center">Date</td>
				<td width="26%" class="thinborder" align="center">Location</td>
				<td width="23%" class="thinborder" align="center">Document #(if any)</td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Personal Survival Techniques </td>
				<% strTemp = WI.fillTextValue("field_12_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp= (String)vEditInfo.elementAt(13);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%strTemp = WI.fillTextValue("field_13");
				  if(vEditInfo !=null && vEditInfo.size()>0)
				  	 strTemp = (String) vEditInfo.elementAt(14);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%strTemp = WI.fillTextValue("field_14");
				  if(vEditInfo!=null && vEditInfo.size()>0)
				  	 strTemp = (String) vEditInfo.elementAt(15);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Fire Prevention & Fire Fighting</td>
				<%strTemp = WI.fillTextValue("field_15_date");
				  if(WI.getStrValue(strTemp).length()==0)
				  	  strTemp = WI.getTodaysDate(1);				
				  if(vEditInfo!=null && vEditInfo.size()>0)
				  	  strTemp= (String)vEditInfo.elementAt(16);				  
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_16");
				   if(vEditInfo!=null && vEditInfo.size()>0)
				      strTemp= (String)vEditInfo.elementAt(17);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_17");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp = (String) vEditInfo.elementAt(18);
				%>				
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Elementary First Aid</td>
				<% strTemp = WI.fillTextValue("field_18_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp= WI.getTodaysDate(1);						
				   if(vEditInfo!=null && vEditInfo.size()>0)
				   		strTemp = (String) vEditInfo.elementAt(19);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp =WI.fillTextValue("field_19");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp = (String)vEditInfo.elementAt(20);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_20");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				       strTemp = (String) vEditInfo.elementAt(21);				
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Personal Safety and Social Responsibilities</td>
				<% strTemp= WI.fillTextValue("field_21_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   	  strTemp =WI.getTodaysDate(1);						
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(22);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp= WI.fillTextValue("field_22");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(23);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_23");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(24);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Others</td>
				<% strTemp= WI.fillTextValue("field_24_date");
				   if(WI.getStrValue(strTemp).length()==0)
					  strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(25);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_25");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(26);
				%>				
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_26");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(27);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	       <tr>
		   		<td height="25"><strong>Record of Other Training</strong></td>
		   </tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	       <tr>
		   		<td width="27%" height="25" class="thinborder">&nbsp;</td>
				<td width="24%" align="center" class="thinborder">Date</td>
				<td width="26%" align="center" class="thinborder">Location</td>
				<td width="23%" align="center" class="thinborder">Document #(if any)</td>
		   </tr>
		   <tr>
		   		<td class="thinborder" height="25">Proficiency in Survival Craft & Rescue Boats</td>
				<% strTemp= WI.fillTextValue("field_27_date");
				   if(WI.getStrValue(strTemp).length()==0)
					  strTemp =WI.getTodaysDate(1);				
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(28);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_28");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(29);
				%>				
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_29");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(30);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		   </tr>
		   <tr>
		   		<td class="thinborder" height="25">Proficiency in Fast Rescue Boats</td>
				<% strTemp= WI.fillTextValue("field_30_date");
				   if(WI.getStrValue(strTemp).length()==0)
					  strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(31);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_31");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(32);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_32");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(33);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		   </tr>
		   <tr>
		   	    <td class="thinborder" height="25">Others</td>
				<% strTemp= WI.fillTextValue("field_33_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(34);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_34");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(35);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_35");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(36);
				%>				
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		   </tr>		   
	   </table>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25"><strong>FOR ALUMNI/SNPL USE</strong></td>
			</tr>
			<tr>
				<td height="25"><strong>SHIPBOARD SERVICE RECORD</strong></td>
			</tr>
	   </table>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF" class="thinborder">
	        <tr>
				<td width="17%" height="25" rowspan="2" align="center" class="thinborder"><strong>Principal</strong></td>
				<td width="11%" rowspan="2" align="center" class="thinborder"><strong>Type of vessel</strong></td>
				<td width="9%" rowspan="2" align="center" class="thinborder"><strong>Position</strong></td>
				<td width="7%" rowspan="2" align="center" class="thinborder"><strong>Allotment</strong></td>
				<td width="6%" rowspan="2" align="center" class="thinborder"><strong>SNPL</strong></td>
				<td class="thinborder" align="center" colspan="2"><strong>Dates</strong></td>
				<td width="10%" rowspan="2" align="center" class="thinborder"><strong>Last Contact</strong></td>
				<td width="6%" rowspan="2" align="center" class="thinborder"><strong>Status</strong></td>
				<td class="thinborder" align="center" colspan="2"><strong>Seagoing service</strong></td>
			</tr>
			<tr>
				<td width="9%" height="25" align="center" class="thinborder"><strong>Embarkation</strong></td>
				<td width="11%" align="center" class="thinborder"><strong>Disembarkation</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Months</strong></td>
				<td width="6%" align="center" class="thinborder"><strong>Days</strong></td>
			</tr>
			<tr>
			    <% strTemp = WI.fillTextValue("field_36");
			       if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(37);
				%>
				<td height="25" class="thinborder">1. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp =WI.fillTextValue("filed_37");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(38);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_38");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(39);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_39");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(40);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp =WI.fillTextValue("field_40");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(41);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%> </td>
				<% strTemp= WI.fillTextValue("field_41_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(42);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp= WI.fillTextValue("field_42_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(43);				  
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_43");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(44);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_44");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(45);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp =WI.fillTextValue("field_45");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(46);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_46");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(47);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_47");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(48);
				%>
				<td height="25" class="thinborder">2. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_48");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(49);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_49");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(50);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_50");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(51);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_51");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(52);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp= WI.fillTextValue("field_52_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(53);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp= WI.fillTextValue("field_53_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(54);				  
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_54");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(55);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_55");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(56);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_56");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(57);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_57");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(58);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_58");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(59);
				%>
				<td height="25" class="thinborder">3. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_59");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(60);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_60");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(61);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_61");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(62);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_62");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(63);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(64);
				   else
					  strTemp= WI.fillTextValue("field_63_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(65);
				   else
					  strTemp= WI.fillTextValue("field_64_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_65");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(66);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_66");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(67);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_67");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(68);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_68");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(69);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_69");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(70);
				%>
				<td height="25" class="thinborder">4. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_70");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(71);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_71");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(72);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_72");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(73);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_73");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(74);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_74_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp= WI.getTodaysDate();
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(75);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_75_date");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(76);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_76");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(77);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_77");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(78);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_78");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(79);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_79");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(80);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
			    <% strTemp = WI.fillTextValue("field_80");
			       if(vEditInfo !=null && vEditInfo.size()>0)
			    	  strTemp = (String) vEditInfo.elementAt(81);
				%>
				<td height="25" class="thinborder">5. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_81");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(82);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_82");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(83);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_83");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(84);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_84");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(85);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_85_date");
				   if(WI.getStrValue(strTemp).length()==0)
				       strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
				       strTemp = (String) vEditInfo.elementAt(86);	
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%  strTemp = WI.fillTextValue("field_86_date");
					if(WI.getStrValue(strTemp).length()==0)
						strTemp = WI.getTodaysDate(1);
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(87);
				%>
				<td height="25" class="thinborder"><%=strTemp%></td>
				<% strTemp = WI.fillTextValue("field_87");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(88);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%  strTemp = WI.fillTextValue("field_88");
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(89);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%   strTemp = WI.fillTextValue("field_89");
					 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(90);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_90");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(91);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
			 	<%  strTemp = WI.fillTextValue("field_91");
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(92);
				%>
				<td height="25" class="thinborder">6. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			    <%  strTemp = WI.fillTextValue("field_92");
			    	if(vEditInfo !=null && vEditInfo.size()>0)
			    		strTemp = (String) vEditInfo.elementAt(93);
				%>
			    <td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_93");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(94);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_94");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 	strTemp = (String) vEditInfo.elementAt(95);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_95");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(96);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%   strTemp = WI.fillTextValue("field_96_date");
					 if(WI.getStrValue(strTemp).length()==0)
					    strTemp= WI.getTodaysDate(1);
				     if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(97);					
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_97_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);		
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(98);				   		
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_98");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(99);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_99");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(100);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_100");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(101);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_101");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(102);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_102");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(103);
				%>
				<td height="25" class="thinborder">7. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_103");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(104);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_104");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(105);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_105");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(106);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_106");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(107);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_107_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(108);				  
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_108_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(109);	
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_109");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(110);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_110");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(111);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_111");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(112);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_112");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(113);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_113");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(114);
				%>
				<td height="25" class="thinborder">8. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_114");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(115);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_115");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(116);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_116");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(117);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_117");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(118);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_118_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(119);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_119_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(120);				   
				%>
				<td height="25" class="thinborder"><%=strTemp%></td>
				<% strTemp = WI.fillTextValue("field_120");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(121);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_121");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(122);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_122");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(123);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_123");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(124);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_124");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(125);
				%>
				<td height="25" class="thinborder">9. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_125");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(126);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_126");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(127);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_127");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(128);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_128");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(129);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%  strTemp = WI.fillTextValue("field_129_date");
					if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
					if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(130);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp =  WI.fillTextValue("field_130_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(131);				  
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_131");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(132);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_132");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(133);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_133");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				    	strTemp = (String) vEditInfo.elementAt(134);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_134");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(135);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_135");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(136);
				%>
				<td height="25" class="thinborder">10. <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_136");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(137);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_137");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(138);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_138");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(139);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_139");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(140);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_140_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate();
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(141);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%  strTemp = WI.fillTextValue("field_141_date");
					if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(142);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_142");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(143);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_143");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(144);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_144");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(145);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_145");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(146);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>     
				<td height="25" class="thinborder">Total Service</td>
				<% strTemp = WI.fillTextValue("field_146");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(147);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_147");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(148);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_148");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(149);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_149");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(150);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_150_date");
				   if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(151);				 
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_151_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(152);				   
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_152");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(153);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_153");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(154);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_154");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(155);
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_155");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(156);  
				%>
				<td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
	   </table>
	   <br>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25"><strong>LEGAL MATTERS</strong></td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
	    	<tr>
				<td height="25" class="thinborder">&nbsp;</td>
				<td class="thinborder" align="center"><strong>Reciever</strong></td>
				<td class="thinborder" align="center"><strong>Address</strong></td>
				<td class="thinborder" align="center"><strong>Date</strong></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Notice Letter</td>
				<% strTemp = WI.fillTextValue("field_156");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(157);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_157");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(158);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_158_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(159);				   				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">1st Demand Letter</td>
				<% strTemp = WI.fillTextValue("field_159");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(160);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_160");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(161);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_161_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(162); 				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Final Demand Letter</td>
				<% strTemp = WI.fillTextValue("field_162");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(163);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_163");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(164);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_164_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp =WI.getTodaysDate(1);
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(165);				   
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Court Filling</td>
				<% strTemp = WI.fillTextValue("field_165");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(166);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<% strTemp = WI.fillTextValue("field_166");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(167);
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<%strTemp = WI.fillTextValue("field_167");
			      if(WI.getStrValue(strTemp).length()==0)
				     strTemp = WI.getTodaysDate(1); 
				  if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(168);				  
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25">Note</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td height="25">Embarkation & Disembarkation(12 months)</td>
				<td>notify after 12 months</td>
			</tr>
			<tr>
				<td height="25">E1/E2</td>
				<td>notify after 10 months</td>
			</tr>
	   </table>
<%}//end of vRetResult[0] !=null && vRetResult[0].size()>0%>
</body>
</html>
<%
dbOP.cleanUP();
%>
