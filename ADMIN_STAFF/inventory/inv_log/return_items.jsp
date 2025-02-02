<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageLoad(){
 	document.form_.req_no.focus();
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.max_items.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp);++i)
			eval('document.form_.return_'+i+'.checked=false');
		
}

function PageAction(strAction,strIndex){
  document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
	document.form_.pageAction.value = strAction;
	document.form_.strIndex.value = strIndex;
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Endorsement, purchasing.Returns, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-ENDORSEMENT-View delivery update Status","delivery_update_status.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.

	String strSchCode = dbOP.getSchoolIndex();	
   if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="delivery_update_status_cpu_print.jsp"/>
   <%}
    
	
	Endorsement EN = new Endorsement();	
	Returns RET = new Returns();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vRetResult = null;
	int iCount = 1;	
	int i = 0;
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = EN.operateOnReqInfoEn(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = EN.getErrMsg();
		else{			
		  if(Integer.parseInt(WI.getStrValue((String)vReqInfo.elementAt(3),"0")) != 1){
		  	strErrMsg = "PO not yet approved";
		  }else{		  
				if(WI.fillTextValue("pageAction").length() > 0){
					vRetResult = RET.operateOnReqItemsReturn(dbOP, request, Integer.parseInt(WI.fillTextValue("pageAction")));
					if(vRetResult == null)
						strErrMsg = RET.getErrMsg();
					else
						strErrMsg = "Operation Successful";
			}

			vRetResult = EN.operateOnReqItemsEn(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = EN.getErrMsg();
			else{
				vReqItems = (Vector)vRetResult.elementAt(1);
				if(vReqItems == null || vReqItems.size() == 0)
					strErrMsg = " No records of endorsed items";
			}	
		 }
	  }
	}
%>	
<form name="form_" method="post" action="endorsement_return_items.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"  align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
          ENDORSEMENT - RETURN ENDORSED ITEMS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="30">&nbsp;</td>
      <td width="20%">PO No. :</td>
			<%if(WI.fillTextValue("req_no").length() > 0){
		  		strTemp = WI.fillTextValue("req_no");
			  }else{
	  			strTemp = "";
      	}%> 			
      <td width="27%"><input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="50%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>
	<%if(vReqInfo != null && vReqInfo.size() > 1){%>
	<%if(vReqItems != null && vReqItems.size() > 1){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEM(S) ENDORSED</strong></font></div></td>
    </tr>
    <tr> 
      <td width="9%" height="27" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="27%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong>TOTAL PRICE</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>RETURN
            <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong>all</div></td>
    </tr>
    <% for(i = 1,iCount = 1;i < vReqItems.size();i+=12,++iCount){%>
    <tr> 
      <td height="26" class="thinborder"><div align="center"><%=iCount%></div></td>
			<input name="itemIndex_<%=iCount%>" type="hidden" value="<%=(String)vReqItems.elementAt(i)%>">
			<%
				strTemp = (String)vReqItems.elementAt(i+10);
			%>
      <td class="thinborder">
    <input type="hidden" name="endorsed_qty_<%=iCount%>" value="<%=strTemp%>">
		<input type="hidden" name="delivered_qty_<%=iCount%>" value="<%=(String)vReqItems.elementAt(i+9)%>">
    <input name="return_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
				value="<%=strTemp%>" size="3" maxlength="10" style="text-align:right">
      </td>
			<td class="thinborder"><div align="center"><%=vReqItems.elementAt(i+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(i+3)%> / <%=vReqItems.elementAt(i+4)%><%=WI.getStrValue((String)vReqItems.elementAt(i+8),"(",")","")%> </div></td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReqItems.elementAt(i+5))]%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItems.elementAt(i+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItems.elementAt(i+7),"&nbsp;")%></div></td>
      <td align="center" class="thinborder"><input type="checkbox" name="return_<%=iCount%>" value="1"></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
      <td height="25" colspan="2" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td class="thinborder"><div align="right"><strong><%=WI.getStrValue(vReqItems.elementAt(0),"&nbsp;")%></strong></div></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp= WI.fillTextValue("reason_index");
			%>
      <td width="95%">Reason for returning item(s) :<br>
        <select name="reason_index">
          <option value="">Select Reason</option>
          <%=dbOP.loadCombo("reason_index","reason"," from pur_preload_reason order by reason", strTemp, false)%>
        </select>
        <font size="1">		
				<a href='javascript:viewList("pur_preload_reason","reason_index","reason",
				"REASON","PUR_RETURN_ITEM","REASON_INDEX"," and is_valid = 1","","reason_index")'>
				<img src="../../../images/update.gif" border="0"></a></font><font size="1">click to UPDATE list of reasons </font></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td>Remarks : <br>
      <textarea name="remarks" cols="40" rows="3"></textarea></td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="center"><font size="1"><a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a>click to SAVE item status change &nbsp;&nbsp;&nbsp;&nbsp;<img src="../../../images/cancel.gif" border="0"> click to Cancel item status change </font></td>
    </tr>
  </table>
	<%}// if vReqItems != null %>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="max_items" value ="<%=iCount-1%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="is_endorsed" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
