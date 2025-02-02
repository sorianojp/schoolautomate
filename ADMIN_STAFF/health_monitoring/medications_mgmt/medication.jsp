<%@ page language="java" import="utility.*, health.MedicationMgmt, java.util.Vector " buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel()
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
			"&table_list="+escape(tablelist)+
			"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
			"&opner_form_name=form_";

	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String [] astrYN = {"No", "Yes"};
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./print_medications.jsp" />
	<%	return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring - Medications Management","medication.jsp");
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
														"Health Monitoring","Medications Management",request.getRemoteAddr(),
														"medication.jsp");
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

	MedicationMgmt medMgmt = new MedicationMgmt();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(medMgmt.operateOnMedicationEntry(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				strPrepareToEdit = "";
				}
		else

				strErrMsg = medMgmt.getErrMsg();
					}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = medMgmt.operateOnMedicationEntry(dbOP, request, 3);
		//System.out.println("My Info: "+vEditInfo);

		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = medMgmt.getErrMsg();
	}

	vRetResult = medMgmt.operateOnMedicationEntry(dbOP, request, 4);
	iSearchResult = medMgmt.getSearchCount();
	if (strErrMsg == null)
		strErrMsg = medMgmt.getErrMsg();

%>

<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./medication.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="61%" height="28" class="footerDynamic" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>::::
          MEDICATIONS MANAGEMENT - MEDICATIONS ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="3%"height="23">&nbsp;</td>
      <td width="16%" height="23" valign="bottom">Medication
        Name</td>
      <td height="23" colspan="2">
      <%
      if (vEditInfo!= null && vEditInfo.size()>0)
            strTemp = (String)vEditInfo.elementAt(1);
      	else
      		strTemp = WI.fillTextValue("med_name_index");%>
      <select name="med_name_index">
          <option value="">Select Name</option>
			<%=dbOP.loadCombo("MEDICATION_NAME_INDEX","MEDICATION_NAME"," FROM HM_PRELOAD_MED_NAME ORDER BY MEDICATION_NAME", strTemp, false)%>
        </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("HM_PRELOAD_MED_NAME","MEDICATION_NAME_INDEX","MEDICATION_NAME","MEDICATIONS",
	"HM_MEDICATION","MEDICATION_NAME_INDEX", " and HM_MEDICATION.IS_DEL = 0 AND HM_MEDICATION.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of medication names</font>
<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Usage/Type</td>
      <td colspan="2">
      <%
      if (vEditInfo!= null && vEditInfo.size()>0)
            strTemp = (String)vEditInfo.elementAt(3);
      	else
		    strTemp = WI.fillTextValue("med_for_index");%>
      <select name="med_for_index">
          <option value="">Select Usage</option>
			<%=dbOP.loadCombo("MEDICATION_FOR_INDEX","MEDICATION_FOR"," FROM HM_PRELOAD_MED_FOR ORDER BY MEDICATION_FOR", strTemp, false)%>
        </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("HM_PRELOAD_MED_FOR","MEDICATION_FOR_INDEX","MEDICATION_FOR","USAGES",
	"HM_MEDICATION","MEDICATION_FOR_INDEX", " and HM_MEDICATION.IS_DEL = 0 AND HM_MEDICATION.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of medication usages</font>
<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Strength</td>
      <td colspan="2"><%
      if (vEditInfo!= null && vEditInfo.size()>0)
            strTemp = (String)vEditInfo.elementAt(5);
      	else
		    strTemp = WI.fillTextValue("med_str_index");%>
      <select name="med_str_index">
          <option value="">Select Strength</option>
			<%=dbOP.loadCombo("MEDICATION_STRENGTH_INDEX","MEDICATION_STRENGTH"," FROM HM_PRELOAD_MED_STRENGTH ORDER BY MEDICATION_STRENGTH", strTemp, false)%>
        </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("HM_PRELOAD_MED_STRENGTH","MEDICATION_STRENGTH_INDEX","MEDICATION_STRENGTH","STRENGTHS",
	"HM_MEDICATION","MEDICATION_STRENGTH_INDEX", " and HM_MEDICATION.IS_DEL = 0 AND HM_MEDICATION.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of medication strengths</font>
<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="bottom">Med. Form</td>
      <td colspan="2">
	  <%
		  if (vEditInfo!= null && vEditInfo.size()>0)
        	    strTemp = (String)vEditInfo.elementAt(7);
    	  	else
			    strTemp = WI.fillTextValue("med_form_index");%>
      <select name="med_form_index">
          <option value="">Select Form</option>
			<%=dbOP.loadCombo("MEDICATION_FORM_INDEX","MEDICATION_FORM"," FROM HM_PRELOAD_MED_FORM ORDER BY MEDICATION_FORM", strTemp, false)%>
        </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("HM_PRELOAD_MED_FORM","MEDICATION_FORM_INDEX","MEDICATION_FORM","MEDICATION FORMS",
	"HM_MEDICATION","MEDICATION_FORM_INDEX", " and HM_MEDICATION.IS_DEL = 0 AND HM_MEDICATION.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of medication forms</font>
<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="bottom">
       <%String strPresc = null;

        if (vEditInfo!= null && vEditInfo.size()>0)
            strPresc = (String)vEditInfo.elementAt(9);
      	else
	        strPresc = WI.fillTextValue("presc");


        if (strPresc.compareTo("1")==0)
        	strTemp = "checked";
       	else
        	strTemp ="";
        %>

       <input type="checkbox" name="presc" value="1" <%=strTemp%>> Is Prescription Required &nbsp;&nbsp;&nbsp;&nbsp;
	   
      <%String strAvail = null;
        if (vEditInfo!= null && vEditInfo.size()>0)
            strAvail = (String)vEditInfo.elementAt(10);
      	else
             strAvail = WI.fillTextValue("avail");

        if (strAvail.compareTo("1")==0)
        	strTemp = "checked";
       	else
        	strTemp ="";
        %>

       <input type="checkbox" name="avail" value="1" <%=strTemp%>> Is Available In Clinic 
	   </td>
    </tr>
    <tr>
      <td height="48">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="64%">
<%if(iAccessLevel > 1) {%>
      <%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to add entry
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
        Click to clear entries
        <%}%> 
<%}%>
		</td>
      <td width="17%"><div align="left"></div></td>
    </tr>
  </table>
 <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
    <td colspan="8" height="25"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
    <tr bgcolor="#FFFF9F">
    <td colspan="8" class="thinborderALL"><div align="center"><strong>LIST OF MEDICATIONS
          IN THE DATABASE </strong></div></td>
    </tr>

    <tr>
      <td width="41%" class="thinborderLEFT"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>TOTAL
        :<strong><%=iSearchResult%></strong></font></td>
      <td width="30%" class="thinborderRIGHT" align="right" style="font-size:9px;">
      <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/medMgmt.defSearchSize;
		if(iSearchResult % medMgmt.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>&nbsp;<%}%>
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr>
      <td width="18%" height="26" class="thinborder"><div align="center"><font size="1"><strong>MEDICATION
          NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>USAGE/TYPE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>STRENGTH</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>MEDICATION FORM</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>PRESCRIPTION
          TYPE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>AVAILABLE IN
          CLINIC</strong></font></div></td>
      <td width="16%" colspan="2" class="thinborder">&nbsp;</td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=11){%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
      <td class="thinborder"><div align="center"><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></div></td>
      <td class="thinborder"><div align="center"><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+10))]%></div></td>
      <td class="thinborder"><div align="center"><font size="1">
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized to edit
        <%}%>
        </font></div></td>
      <td class="thinborder"><div align="center"><font size="1">
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete
        <%}%>
        </font></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9" class="footerDynamic" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  	<input type="hidden" name="print_page">
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
